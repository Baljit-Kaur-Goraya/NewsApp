//
//  ViewController.swift
//  NewsApp
//
//  Created by Mac on 10/10/20.
//  Copyright © 2020 baljit. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    var articles: [Article]? = []
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchjson()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    func fetchjson()
    {
        guard let url = URL(string: "https://newsapi.org/v1/articles?source=bbc-news&sortBy=top&apiKey=4dbc17e007ab436fb66416009dfb59a8") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let response = response
            {
                print(response)
            }
            self.articles = [Article]()
            do
            {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! [String: AnyObject]
                print(json)
                if let articlesFromJson = json["articles"] as? [[String: Any]]
                {
                    for articleFromJson in articlesFromJson
                    {
                        let article = Article()
                        if let title = articleFromJson["title"] as? String, let author = articleFromJson["author"] as? String, let desc = articleFromJson["description"] as? String, let url = articleFromJson["url"] as? String, let urlImage = articleFromJson["urlToImage"] as? String
                        {
                            article.author = author
                            article.desc = desc
                            article.headline = title
                            article.url = url
                            article.imageUrl = urlImage
                        }
                        self.articles?.append(article)
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            catch let error
            {
                print(error.localizedDescription)
            }
            
        }
        task.resume()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articles?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.title.text = self.articles?[indexPath.row].headline
        cell.desc.text = self.articles?[indexPath.row].desc
        cell.author.text = self.articles?[indexPath.row].author
        cell.imgView.downloadImage(from: (self.articles?[indexPath.item].imageUrl!)!)
        return cell
    }
}

extension UIImageView
{
    func downloadImage(from url: String)
    {
        let urlRequest = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error != nil{
                print(error ?? "Unknown")
                return
            }
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
        }
        task.resume()
    }
}
