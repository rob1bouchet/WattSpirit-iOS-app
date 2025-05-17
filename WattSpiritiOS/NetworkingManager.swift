//
//  NetworkingManager.swift
//  WattSpiritiOS
//
//  Created by Robin Bouchet on 17/05/2025.
//

import Foundation

class NetworkingManager {
    
    static let loginURL = URL(string: "https://my.wattspirit.com/api/")!
    
    func login(username: String, password: String) async throws {
        let credentials = "\(username):\(password)"
        guard let encodedCredentials = credentials.data(using: .utf8)?.base64EncodedString() else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: Self.loginURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(encodedCredentials)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("https://my.wattspirit.com/front/", forHTTPHeaderField: "Referer")

        let (data, response) = try await URLSession.shared.data(for: request)
        print("Response: \(response)")
        print("Data: \(String(data: data, encoding: .utf8) ?? "")")

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        let loginResponse = try decoder.decode(LoginResponse.self, from: data)
        print("Login successful, token: \(loginResponse.token)")
        UserDefaults.standard.set(loginResponse.token, forKey: "token")
    }

    func refreshToken() {
        // To be implemented
    }

    func getData(startDate: Date, endDate: Date) async throws -> [ConsumptionData] {
        let calendar = Calendar(identifier: .iso8601)
        var results: [ConsumptionData] = []

        var chunkStart = startDate

        while chunkStart < endDate {
            let chunkEnd = calendar.date(byAdding: .day, value: 6, to: chunkStart)!
            let adjustedEnd = min(chunkEnd, endDate)
            let dataChunk = try await fetchDataChunk(start: chunkStart, end: adjustedEnd)
            results.append(dataChunk)

            guard let nextStart = calendar.date(byAdding: .day, value: 7, to: chunkStart) else { break }
            chunkStart = nextStart
        }

        return results
    }

    private func fetchDataChunk(start: Date, end: Date) async throws -> ConsumptionData {
        let startTimestamp = Int(start.timeIntervalSince1970)
        let endTimestamp = Int(end.timeIntervalSince1970)

        let urlString = "https://my.wattspirit.com/api/smk/p1m/\(startTimestamp)/\(endTimestamp)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = UserDefaults.standard.string(forKey: "token") {
            request.setValue("\(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        let chunk = try decoder.decode(ConsumptionData.self, from: data)
        return chunk
    }
}
