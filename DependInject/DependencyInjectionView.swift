//
//  DependencyInjectionView.swift
//  DependInject
//
//  Created by Maziar Layeghkar on 01.06.24.
//

import SwiftUI
import Combine

struct DependencyInjectionModel: Identifiable, Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

class DependencyInjectionDataService {
    static let instance = DependencyInjectionDataService()
    
    let url: URL = URL(string: "https://jsonplaceholder.typicode.com/posts")!
    
    func getData() -> AnyPublisher<[DependencyInjectionModel], Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [DependencyInjectionModel].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

class DependencyInjectionViewModel: ObservableObject {
    
    var cancellables = Set<AnyCancellable>()
    
    @Published var posts: [DependencyInjectionModel] = []
    
    init() {
        loadData()
    }
    
    private func loadData() {
        DependencyInjectionDataService.instance.getData()
            .sink { _ in
                
            } receiveValue: { [weak self] returnedData in
                self?.posts = returnedData
            }
            .store(in: &cancellables)
    }
}

struct DependencyInjectionView: View {
    
    @StateObject private var viewModel = DependencyInjectionViewModel()
    
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

#Preview {
    DependencyInjectionView()
}
