//Swift 4.0


//Multi line Strings
let myStr = """
Cuando escribimos un string multilínea
podemos hacer intro cada vez que queramos.
Simplemente es una forma más natural de escribir texto.
Y si queríais un bonus para esta clase,
deciros que, los string multilínea
también permiten comillas dobles dentro de ellos.

    Por ejemplo,   esta frase la ha escrito "Juan Gabriel"
para su curso más completo de "iOS 11" hasta la fecha.
"""

print(myStr)


//Strings y colecciones

let testStr = "Hola, soy Juan Gabriel."

let characters = testStr.characters

for c in testStr {
    print(c)
}

print("String invertido")
for c in testStr.reversed(){
    print(c)
}

//Rangos unilaterales

let food = ["Pizza", "Panacotta", "Spaguetti", "Lubina a la sal", "Mejillón tigre", "Ensalada César"]

let italianFood = food[..<3]

let fishFood = food[3...]

let menu = food[1...3]


//Diccionarios

let cities = ["Madrid":3_165_541, "Barcelona":1_608_746, "Sevilla":690_566, "Palma de Mallorca":402_949, "Oviedo":220_567, "Santa Cruz de Tenerife": 203_585]


let massiveCities = cities.filter{$0.value>500_000}
print(massiveCities)
//massiveCities["Madrid"] X
//massiveCities[0].values OK

let population = cities.map{$0.value*3}
print(population)

let newPopulation = cities.mapValues {"\($0/1_000) miles de personas" }
print(newPopulation)

let groupedCities = Dictionary(grouping:cities.keys){$0.characters.first!}
print(groupedCities)

let groupedPopulationCities = Dictionary(grouping:cities.keys){$0.count}
print(groupedPopulationCities)

let person = ["name":"Juan Gabriel", "city": "Palma"]
let name = person["dni"] ?? "Unknown"
print(name)

let favouriteSinger = ["Coldplay", "Madonna", "Justin Bieber", "Madonna", "Paco de Lucía", "Madonna", "Coldplay"]
var favouriteCounts = [String:Int]()

for singer in favouriteSinger {
    favouriteCounts[singer, default: 0] += 1
}

print(favouriteCounts)

let people = [("John","Lennon"), ("Juan Gabriel", "Gomila"), ("Madonna", "Ciccone"), ("Christian", "Grey")]

let namesDict = Dictionary(uniqueKeysWithValues:people)
print(namesDict["Madonna"] ?? "Persona no invitada")

let squaredNumbers = [1,4,9,16,25,36]

let combinedNumbers = Dictionary(uniqueKeysWithValues: zip(1...,squaredNumbers))
print(combinedNumbers)
