//
//  DependencyInjectionView.swift
//  DependInject
//
//  Created by Maziar Layeghkar on 01.06.24.
//

import SwiftUI
import Combine

struct PostsModel: Identifiable, Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

protocol DataServiceProtocol {
    func getData() -> AnyPublisher<[PostsModel], Error>
}

class ProductionDataService: DataServiceProtocol {
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func getData() -> AnyPublisher<[PostsModel], Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [PostsModel].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

class MockDataService: DataServiceProtocol {
    
    let testData: [PostsModel]
    
    init(testData: [PostsModel]?) {
        self.testData = testData ?? [
            PostsModel(userId: 1, id: 1, title: "One", body: "one"),
            PostsModel(userId: 2, id: 2, title: "Two", body: "two")
        ]
    }
    
    func getData() -> AnyPublisher<[PostsModel], Error> {
        Just(testData)
            .tryMap { $0 }
            .eraseToAnyPublisher()
    }
}

class DependencyInjectionViewModel: ObservableObject {
    
    var cancellables = Set<AnyCancellable>()
    let dataService: DataServiceProtocol
    
    @Published var posts: [PostsModel] = []
    
    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
        loadData()
    }
    
    private func loadData() {
        dataService.getData()
            .sink { _ in
                
            } receiveValue: { [weak self] returnedData in
                self?.posts = returnedData
            }
            .store(in: &cancellables)
    }
}

struct DependencyInjectionView: View {
    
    @StateObject private var viewModel: DependencyInjectionViewModel
    
    init(dataService: DataServiceProtocol) {
        _viewModel = StateObject(wrappedValue: DependencyInjectionViewModel(dataService: dataService))
    }
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.posts) { post in
                    Text(post.title)
                }
            }
        }
    }
}

struct DependencyInjectionView_Previews: PreviewProvider {
    //static let dataService = ProductionDataService(url: URL(string: "https://jsonplaceholder.typicode.com/posts")!)
    
    //static let dataService = MockDataService(testData: nil)
    
    static let dataService = MockDataService(testData: 
    [
        PostsModel(userId: 1234, id: 1234, title: "Test", body: "test"),
    ])
    
    static var previews: some View {
        DependencyInjectionView(dataService: dataService)
    }
    
}
