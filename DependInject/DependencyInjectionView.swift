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
    
    let testData: [PostsModel] = [
        PostsModel(userId: 1, id: 1, title: "One", body: "one"),
        PostsModel(userId: 2, id: 2, title: "Two", body: "two")
    ]
    
    func getData() -> AnyPublisher<[PostsModel], any Error> {
        
    }
    
    
}

class DependencyInjectionViewModel: ObservableObject {
    
    var cancellables = Set<AnyCancellable>()
    let dataService: ProductionDataService
    
    @Published var posts: [PostsModel] = []
    
    init(dataService: ProductionDataService) {
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
    
    init(dataService: ProductionDataService) {
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
    static let dataService = ProductionDataService(url: URL(string: "https://jsonplaceholder.typicode.com/posts")!)
    
    static var previews: some View {
        DependencyInjectionView(dataService: dataService)
    }
    
}
