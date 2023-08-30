//
//  ViewController.swift
//  Apuntes
//
//  Created by Juan Gabriel Gomila Salas on 1/7/17.
//  Copyright © 2017 Frogames. All rights reserved.
//

import UIKit
import PDFKit
import SafariServices

class ViewController: UIViewController, PDFViewDelegate, PDFDocumentDelegate {
    
    let pdfView = PDFView()
    
    let textview = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configuración de PDF VIew
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)
        
        pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        //Configuración de Text View
        textview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textview)
        
        textview.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        textview.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        textview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive  = true
        textview.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        textview.isEditable = false
        textview.isHidden = true
        textview.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        //Métodos de uso del PDF
        let search = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(promptForSearch))
        let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareSelection))
        
        let previous = UIBarButtonItem(barButtonSystemItem: .rewind, target: self.pdfView, action: #selector(PDFView.goToPreviousPage(_:)))
        let next = UIBarButtonItem(barButtonSystemItem: .fastForward, target: self.pdfView, action: #selector(PDFView.goToNextPage(_:)))
        
        
        self.navigationItem.leftBarButtonItems = [search, share, previous, next]
        
        
        self.pdfView.autoScales = true
        self.pdfView.delegate = self
        
        
        let pdfMode = UISegmentedControl(items: ["PDF", "Solo Texto"])
        pdfMode.addTarget(self, action: #selector(changePDFMode), for: .valueChanged)
        pdfMode.selectedSegmentIndex = 0
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: pdfMode)
        self.navigationItem.rightBarButtonItem?.width = 160
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func load(_ name: String) {
        //Convertir el nombre del libro al nombre del fichero
        let filename = name.replacingOccurrences(of: " ", with: "_").lowercased()
        
        //Buscar dentro del paquete de recursos (bundle) el archivo con extensión pdf
        guard let path = Bundle.main.url(forResource: filename, withExtension: "pdf") else {
            return
        }
        
        //Cargar el PDF usando la clase PDFDocument, con una URL
        if let document = PDFDocument(url: path){
            //Asignar el PDFDocument a la PDFView de nuestra app
            document.delegate = self
            self.pdfView.document = document
            
            //self.pdfView.displayMode = .singlePage
            
            //Llamar al método goToFirstPage()
            self.pdfView.goToFirstPage(nil)
            
            self.readText()
            
            //Mostrar el nombre del fichero en la barra de título del iPad.
            if UIDevice.current.userInterfaceIdiom == .pad {
                title = name
            }
        }
    }
    
    
    @objc func promptForSearch(){
        let alert = UIAlertController(title: "Buscar", message: nil, preferredStyle: .alert)
        alert.addTextField()
        
        alert.addAction(UIAlertAction(title: "Buscar", style: .default, handler:
            { action in
                guard let searchText = alert.textFields?[0].text else { return }
                
                guard let match = self.pdfView.document?.findString(searchText, fromSelection: self.pdfView.highlightedSelections?.first, withOptions: .caseInsensitive) else {return}
                
                self.pdfView.go(to: match)
                
                self.pdfView.highlightedSelections = [match]
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    
    @objc func shareSelection(sender: UIBarButtonItem){
        
        guard let selection = self.pdfView.currentSelection?.attributedString else{
            let alert = UIAlertController(title: "No hay nada seleccionado", message: "Selecciona un fragmento del archivo para compartir.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [selection], applicationActivities: nil)
        activityVC.popoverPresentationController?.barButtonItem = sender
        
        present(activityVC, animated:  true)
    }
    
    
    func pdfViewWillClick(onLink sender: PDFView, with url: URL) {
        let viewcontroller = SFSafariViewController(url: url)
        viewcontroller.modalPresentationStyle = .formSheet
        present(viewcontroller, animated: true)
        
    }
    
    
    @objc func changePDFMode(segmentedControl: UISegmentedControl){
        if segmentedControl.selectedSegmentIndex == 0 {
            //Mostrar PDF
            pdfView.isHidden = false
            textview.isHidden = true
        } else {
            //Mostrar Texto
            pdfView.isHidden = true
            textview.isHidden = false
        }
    }
    
    
    func readText() {
        guard let pageCount = self.pdfView.document?.pageCount else { return }
        
        let pdfContent = NSMutableAttributedString()
        
        let space = NSAttributedString(string: "\n\n\n")
        
        for i in 1..<pageCount {
            guard let page = self.pdfView.document?.page(at: i) else { continue }
            guard let pageContent = page.attributedString else { continue }
            
            pdfContent.append(space)
            pdfContent.append(pageContent)
        }
        
        
        
        let pattern = "https://[a-z0-9].[a-z]"
        let regexp = try? NSRegularExpression(pattern: pattern)
        let range = NSMakeRange(0, pdfContent.string.utf16.count)
        
        if let matches = regexp?.matches(in: pdfContent.string, options: [], range: range) {
            for match in matches.reversed() {
                pdfContent.replaceCharacters(in: match.range, with: "")
            }
        }
        
        
        self.textview.attributedText = pdfContent
    }
    
    func classForPage() -> AnyClass {
        return Watermark.self
    }

}

