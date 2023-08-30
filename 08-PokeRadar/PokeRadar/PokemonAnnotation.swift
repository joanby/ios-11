//
//  PokemonAnnotation.swift
//  PokeRadar
//
//  Created by Juan Gabriel Gomila Salas on 3/7/17.
//  Copyright © 2017 Frogames. All rights reserved.
//

import Foundation
import MapKit

class PokemonAnnotation: NSObject, MKAnnotation {
    
    var coordinate = CLLocationCoordinate2D()
    var pokemon: Pokemon
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, pokemonId: Int ) {
        self.coordinate = coordinate
        self.pokemon = PokemonFactory.shared.getPokemon(with: pokemonId)
        self.title = self.pokemon.name
    }
    
    
}
