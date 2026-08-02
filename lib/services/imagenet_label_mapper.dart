/// Maps ImageNet class names (from MobileNet) onto the short English
/// keywords that [CategoryEngine] / [SynonymEngine] already understand.
///
/// ImageNet labels are specific ("golden retriever", "sports car", "espresso");
/// without this bridge they would never hit our category needles ("dog", "car",
/// "coffee") and TFLite would be useless for PinPic search.
class ImagenetLabelMapper {
  /// Returns search/category keywords derived from a raw ImageNet label.
  /// Always includes a cleaned form of the original label itself.
  static List<String> expand(String imagenetLabel) {
    final cleaned = imagenetLabel
        .trim()
        .toLowerCase()
        .replaceAll('_', ' ')
        .replaceAll('-', ' ');
    if (cleaned.isEmpty || cleaned == 'background') return const [];

    final out = <String>{};
    // Keep useful tokens from the original label (skip very short noise).
    for (final token in cleaned.split(RegExp(r'\s+'))) {
      if (token.length >= 3) out.add(_capitalize(token));
    }

    void addAll(Iterable<String> labels) => out.addAll(labels);

    if (_matches(cleaned, _dogNeedles)) {
      addAll(const ['Dog', 'Animal', 'Pet']);
    }
    if (_matches(cleaned, _catNeedles)) {
      addAll(const ['Cat', 'Animal', 'Pet']);
    }
    if (_matches(cleaned, _birdNeedles)) {
      addAll(const ['Bird', 'Animal', 'Wildlife']);
    }
    if (_matches(cleaned, _horseNeedles)) {
      addAll(const ['Horse', 'Animal']);
    }
    if (_matches(cleaned, _fishNeedles)) {
      addAll(const ['Fish', 'Animal']);
    }
    // Soft toys: ImageNet "teddy / teddy bear" must NOT become live Animal —
    // MobileNet often confuses cameras / desk clutter with teddy, which then
    // dumped the photo into «Животные».
    if (_matches(cleaned, _teddyNeedles)) {
      out.remove('Bear');
      out.remove('Teddy');
      addAll(const ['Toy', 'Teddy']);
    } else if (_matches(cleaned, _otherAnimalNeedles)) {
      addAll(const ['Animal', 'Wildlife']);
    }
    if (_matches(cleaned, _cameraNeedles)) {
      addAll(const ['Camera', 'Photo']);
    }
    if (_matches(cleaned, _carNeedles)) {
      addAll(const ['Car', 'Vehicle', 'Automobile']);
    }
    if (_matches(cleaned, _bikeNeedles)) {
      addAll(const ['Bicycle', 'Bike', 'Vehicle']);
    }
    if (_matches(cleaned, _motoNeedles)) {
      addAll(const ['Motorcycle', 'Vehicle']);
    }
    if (_matches(cleaned, _truckNeedles)) {
      addAll(const ['Truck', 'Vehicle', 'Car']);
    }
    if (_matches(cleaned, _busNeedles)) {
      addAll(const ['Bus', 'Vehicle']);
    }
    if (_matches(cleaned, _trainNeedles)) {
      addAll(const ['Train', 'Vehicle']);
    }
    if (_matches(cleaned, _planeNeedles)) {
      addAll(const ['Airplane', 'Aircraft', 'Plane']);
    }
    if (_matches(cleaned, _boatNeedles)) {
      addAll(const ['Boat', 'Ship', 'Yacht']);
    }
    if (_matches(cleaned, _foodNeedles)) {
      addAll(const ['Food', 'Meal', 'Dish']);
    }
    if (_matches(cleaned, _drinkNeedles)) {
      addAll(const ['Coffee', 'Drink', 'Beverage', 'Food']);
    }
    if (_matches(cleaned, _plantNeedles)) {
      addAll(const ['Plant', 'Flower', 'Tree']);
    }
    if (_matches(cleaned, _personNeedles)) {
      addAll(const ['Person', 'People', 'Human', 'Face']);
    }
    // Explicitly reject rock/stone-like labels from ever becoming Food —
    // this is the exact failure mode we saw with ML Kit Image Labeling.
    if (_matches(cleaned, _rockNeedles)) {
      out.remove('Food');
      out.remove('Meal');
      out.remove('Dish');
      addAll(const ['Stone', 'Rock']);
    }

    return out.toList(growable: false);
  }

  static bool _matches(String label, List<String> needles) {
    for (final needle in needles) {
      if (label.contains(needle)) return true;
    }
    return false;
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  static const _dogNeedles = [
    'dog',
    'retriever',
    'terrier',
    'spaniel',
    'hound',
    'poodle',
    'bulldog',
    'shepherd',
    'husky',
    'chihuahua',
    'beagle',
    'collie',
    'pug',
    'dalmatian',
    'corgi',
    'mastiff',
    'boxer',
    'doberman',
    'rottweiler',
    'labrador',
    'malamute',
    'samoyed',
    'pekinese',
    'papillon',
    'chow',
    'kelpie',
    'malinois',
    'affenpinscher',
    'basenji',
    'whippet',
    'greyhound',
    'wolfhound',
    'sheepdog',
    'pinscher',
  ];

  static const _catNeedles = [
    'cat',
    'tabby',
    'persian',
    'siamese',
    'egyptian',
    'tiger cat',
    'lynx',
    'cougar',
    'leopard',
    'jaguar',
    'cheetah',
    'lion',
    'tiger',
  ];

  static const _birdNeedles = [
    'bird',
    'jay',
    'magpie',
    'chickadee',
    'finch',
    'sparrow',
    'robin',
    'parrot',
    'macaw',
    'cockatoo',
    'peacock',
    'owl',
    'eagle',
    'hawk',
    'falcon',
    'vulture',
    'crane',
    'stork',
    'flamingo',
    'pelican',
    'penguin',
    'swan',
    'duck',
    'goose',
    'hen',
    'cock',
    'ostrich',
    'hummingbird',
    'woodpecker',
    'kingfisher',
  ];

  static const _horseNeedles = ['horse', 'zebra', 'pony', 'arabian'];
  static const _fishNeedles = [
    'fish',
    'shark',
    'goldfish',
    'ray',
    'barracuda',
    'eel',
    'salmon',
  ];
  static const _teddyNeedles = ['teddy', 'teddy bear'];

  static const _cameraNeedles = [
    'reflex camera',
    'digital camera',
    'polaroid camera',
    'movie camera',
    'camera',
  ];

  static const _otherAnimalNeedles = [
    'bear',
    'wolf',
    'fox',
    'deer',
    'elk',
    'moose',
    'elephant',
    'giraffe',
    'monkey',
    'gorilla',
    'chimpanzee',
    'orangutan',
    'rabbit',
    'hare',
    'squirrel',
    'hamster',
    'mouse',
    'rat',
    'snake',
    'lizard',
    'turtle',
    'tortoise',
    'frog',
    'toad',
    'spider',
    'butterfly',
    'bee',
    'ant',
    'cow',
    'ox',
    'bull',
    'sheep',
    'goat',
    'pig',
    'boar',
    'camel',
    'llama',
    'kangaroo',
    'koala',
    'panda',
    'raccoon',
    'skunk',
    'otter',
    'seal',
    'walrus',
    'dolphin',
    'whale',
    'jellyfish',
    'crab',
    'lobster',
    'snail',
  ];

  static const _carNeedles = [
    'car',
    'cab',
    'taxi',
    'limousine',
    'convertible',
    'coupe',
    'sedan',
    'jeep',
    'minivan',
    'racer',
    'beach wagon',
    'model t',
    'go-kart',
    'golf cart',
  ];
  static const _bikeNeedles = ['bicycle', 'mountain bike', 'tricycle'];
  static const _motoNeedles = ['motorcycle', 'moped', 'scooter', 'motor scooter'];
  static const _truckNeedles = [
    'truck',
    'pickup',
    'trailer truck',
    'fire engine',
    'garbage truck',
    'tow truck',
    'moving van',
  ];
  static const _busNeedles = ['bus', 'trolleybus', 'minibus', 'school bus'];
  static const _trainNeedles = [
    'train',
    'locomotive',
    'streetcar',
    'tram',
    'passenger car',
  ];
  static const _planeNeedles = [
    'airliner',
    'airplane',
    'warplane',
    'airship',
    'balloon',
    'helicopter',
  ];
  static const _boatNeedles = [
    'boat',
    'ship',
    'yacht',
    'canoe',
    'catamaran',
    'speedboat',
    'lifeboat',
    'fireboat',
    'gondola',
    'schooner',
    'container ship',
    'liner',
    'submarine',
  ];

  static const _foodNeedles = [
    'pizza',
    'burger',
    'cheeseburger',
    'hotdog',
    'hot dog',
    'bagel',
    'pretzel',
    'bread',
    'baguette',
    'croissant',
    'doughnut',
    'cake',
    'trifle',
    'ice cream',
    'ice lolly',
    'popsicle',
    'chocolate',
    'candy',
    'apple',
    'orange',
    'banana',
    'lemon',
    'fig',
    'pineapple',
    'strawberry',
    'grape',
    'pomegranate',
    'custard apple',
    'guacamole',
    'hummus',
    'soup',
    'consomme',
    'hot pot',
    'potpie',
    'burrito',
    'carbonara',
    'spaghetti',
    'ravioli',
    'meat loaf',
    'steak',
    'bacon',
    'restaurant',
    'grocery',
    'mashed potato',
    'french fries',
    'broccoli',
    'cauliflower',
    'cucumber',
    'zucchini',
    'bell pepper',
    'head cabbage',
    'artichoke',
    'corn',
    'acorn squash',
    'butternut squash',
    'cardoon',
    'egg',
    'cheese',
    'sushi',
  ];

  static const _drinkNeedles = [
    'espresso',
    'coffee',
    'teapot',
    'wine',
    'beer',
    'red wine',
    'eggnog',
  ];

  static const _plantNeedles = [
    'daisy',
    'yellow lady',
    'flower',
    'rose',
    'hibiscus',
    'tree',
    'oak',
    'pine',
    'willow',
    'palm',
    'pot',
    'vase',
    'mushroom',
    'agaric',
    'gyromitra',
    'stinkhorn',
    'earthstar',
    'hen of the woods',
    'coral fungus',
    'bolete',
  ];

  static const _personNeedles = [
    'person',
    'groom',
    'bridegroom',
    'scuba diver',
    'ballplayer',
  ];

  static const _rockNeedles = [
    'stone',
    'rock',
    'cliff',
    'pebble',
    'gravel',
    'boulder',
    'volcano',
    'mountain',
    'valley',
    'alp',
  ];
}
