//
//  ViewController.swift
//  weatherApp
//
//  Created by 백시훈 on 7/11/24.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    private let urlQuertyItem: [URLQueryItem] = [
        URLQueryItem(name: "lat", value: "37.5"),
        URLQueryItem(name: "lon", value: "126.9"),
        URLQueryItem(name: "appid", value: "1a6a9fee70c2dc58e3358dec1c5e4408"),
        URLQueryItem(name: "units", value: "metric")
    ]
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "서울특별시"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 30)
        return label
    }()
    
    private let tempLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "20도"
        label.font = .boldSystemFont(ofSize: 50)
        return label
    }()
    
    private let tempMinLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "20도"
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let tempMaxLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "20도"
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    private let tempStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchCurrentWeahterData()
    }
    
    //서버 데이터를 불러오는 메서드
    private func fetchData<T: Decodable>(url: URL, completion: @escaping (T?) -> Void){
        let session = URLSession(configuration: .default)
        session.dataTask(with: URLRequest(url: url)){ data, response, error in
            guard let data, error == nil else{
                print("데이터 로드 실패")
                completion(nil)
                return
            }
            let range = 200..<300
            if let response = response as? HTTPURLResponse, range.contains(response.statusCode){
                guard let decodedData = try? JSONDecoder().decode(T.self, from: data)else{
                    print("JSON 디코딩 실패")
                    completion(nil)
                    return
                }
                completion(decodedData)
            } else {
                print("응답 오류")
                completion(nil)
            }
        }.resume()
    }
    
    private func fetchCurrentWeahterData(){
        var urlComponents = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")
        urlComponents?.queryItems = self.urlQuertyItem
        
        guard let url = urlComponents?.url else{
            print("잘못된 URL")
            return
        }
        fetchData(url: url) { [weak self] (result: CurrentWeatherResult?) in
            guard let self, let result else { return }
            
            DispatchQueue.main.async {
                self.tempLabel.text = "\(Int(result.main.temp))℃"
                self.tempMinLabel.text = "최소: \(Int(result.main.tempMin))℃"
                self.tempMaxLabel.text = "최고: \(Int(result.main.tempMax))℃"
            }
            
            guard let imageUrl = URL(string: "https://openweathermap.org/img/wn/\(result.weather[0].icon)@2x.png")else{
                return
            }
            if let data = try? Data(contentsOf: imageUrl){
                if let image = UIImage(data: data){
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }
            }
        }
    }
    
    private func configureUI(){
        view.backgroundColor = .black
        [titleLabel, tempLabel, tempStackView, imageView
        ].forEach {    view.addSubview($0)    }
        
        [
            tempMaxLabel,
            tempMinLabel
        ].forEach{tempStackView.addArrangedSubview($0)}
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(120)
        }
        tempLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
        tempStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(tempLabel.snp.bottom).offset(10)
        }
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(160)
            $0.top.equalTo(tempStackView.snp.bottom).offset(20)
        }
    }

}

