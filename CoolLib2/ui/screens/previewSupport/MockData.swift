struct MockCategories {

    static let list: [Category] = [
        Category(
            id: 1,
            name: "Programming",
            description: "",
            coverUrl: "https://picsum.photos/240"
        ),
        Category(
            id: 2,
            name: "History",
            description: "",
            coverUrl: "https://picsum.photos/241"
        ),
        Category(
            id: 3,
            name: "Science",
            description: "",
            coverUrl: "https://picsum.photos/242"
        ),
        Category(
            id: 4,
            name: "Fantasy",
            description: "",
            coverUrl: "https://picsum.photos/243"
        )
    ]
}

struct MockBooks {

    static let list: [Book] = [

        Book(
            id: 262,
            isbn: "9780099590088",
            title: "Sapiens: A Brief History of Humankind",
            author: "Yuval Noah Harari",
            publisher: "Vintage",
            year: 2011,
            available: true,
            description: nil,
            coverUrl: "\(APIConfig.serverURL)/img/cover/9780099590088.webp"
        ),

        Book(
            id: 270,
            isbn: "9780132350884",
            title: "Clean Code",
            author: "Robert C. Martin",
            publisher: "Prentice Hall",
            year: 2008,
            available: true,
            description: nil,
            coverUrl: "\(APIConfig.serverURL)/img/cover/9780132350884.webp"
        ),

        Book(
            id: 243,
            isbn: "9780812513738",
            title: "The Shadow Rising (The Wheel of Time, Book 4)",
            author: "Robert Jordan",
            publisher: "Tor Books",
            year: 1992,
            available: true,
            description: nil,
            coverUrl: "\(APIConfig.serverURL)/img/cover/9780812513738.webp"
        ),

        Book(
            id: 255,
            isbn: "9780618640195",
            title: "The Lord of the Rings",
            author: "J.R.R. Tolkien",
            publisher: "Houghton Mifflin Harcourt",
            year: 1954,
            available: true,
            description: nil,
            coverUrl: "\(APIConfig.serverURL)/img/cover/9780618640195.webp"
        ),

        Book(
            id: 258,
            isbn: "9780141439518",
            title: "Pride and Prejudice",
            author: "Jane Austen",
            publisher: "Penguin Classics",
            year: 1813,
            available: true,
            description: nil,
            coverUrl: "\(APIConfig.serverURL)/img/cover/9780141439518.webp"
        ),

        Book(
            id: 274,
            isbn: "9780142437230",
            title: "Don Quixote",
            author: "Miguel de Cervantes",
            publisher: "Penguin Classics",
            year: 1605,
            available: true,
            description: nil,
            coverUrl: "\(APIConfig.serverURL)/img/cover/9780142437230.webp"
        ),

        Book(
            id: 265,
            isbn: "9780553380163",
            title: "A Brief History of Time",
            author: "Stephen Hawking",
            publisher: "Bantam",
            year: 1988,
            available: true,
            description: nil,
            coverUrl: "\(APIConfig.serverURL)/img/cover/9780553380163.webp"
        ),

        Book(
            id: 268,
            isbn: "9780714832470",
            title: "The Story of Art",
            author: "E.H. Gombrich",
            publisher: "Phaidon Press",
            year: 1950,
            available: true,
            description: nil,
            coverUrl: "\(APIConfig.serverURL)/img/cover/9780714832470.webp"
        ),

        Book(
            id: 271,
            isbn: "9780201633610",
            title: "Design Patterns",
            author: "Erich Gamma et al.",
            publisher: "Addison-Wesley",
            year: 1994,
            available: true,
            description: nil,
            coverUrl: "\(APIConfig.serverURL)/img/cover/9780201633610.webp"
        ),

        Book(
            id: 272,
            isbn: "9780131103627",
            title: "The C Programming Language",
            author: "Brian W. Kernighan",
            publisher: "Prentice Hall",
            year: 1978,
            available: true,
            description: nil,
            coverUrl: "\(APIConfig.serverURL)/img/cover/9780131103627.webp"
        ),

        Book(
            id: 248,
            isbn: "9780812575583",
            title: "Winter's Heart (The Wheel of Time, Book 9)",
            author: "Robert Jordan",
            publisher: "Tor Books",
            year: 2000,
            available: false,
            description: nil,
            coverUrl: "\(APIConfig.serverURL)/img/cover/9780812575583.webp"
        ),

        Book(
            id: 253,
            isbn: "9780765325969",
            title: "A Memory of Light (The Wheel of Time, Book 14)",
            author: "Robert Jordan & Brandon Sanderson",
            publisher: "Tor Books",
            year: 2013,
            available: true,
            description: nil,
            coverUrl: "\(APIConfig.serverURL)/img/cover/9780765325969.webp"
        )
    ]
}



struct MockCart {

    static let list: [Cart] = MockBooks.list.shuffled().prefix(7).map {
        Cart(
            id: $0.id,
            isbn: $0.isbn,
            title: $0.title,
            author: $0.author,
            publisher: $0.publisher,
            coverUrl: $0.coverUrl
        )
    }
}

struct MockWishlist {

    static let list: [Wishlist] = MockBooks.list.shuffled().prefix(3).map {
        Wishlist(
            id: $0.id,
            isbn: $0.isbn,
            title: $0.title,
            author: $0.author,
            publisher: $0.publisher,
            coverUrl: $0.coverUrl
        )
    }

}
