//
//  ContentView.swift
//  test
//
//  Created by İsmail Oktay Dak on 30.09.2024.
//

import SwiftUI
import CoreData
import MapKit
import Charts

struct ChargeStation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let type: StationType
    let provider: ChargingProvider
}

enum StationType: String, CaseIterable {
    case acNormal = "AC Normal Şarj"
    case dcFast = "DC Hızlı Şarj"
}

enum ChargingProvider: String, CaseIterable {
    case astorSarj = "Astor Şarj"
    case echarge = "Eşarj"
    case otojet = "OTOJET"
    case sarjSepeti = "SarjSepeti"
    case voltrun = "Voltrun"
    case watMobilite = "wat Mobilite"
    case chargeMate = "ChargeMate"
    case gioev = "GIOev"
    case plugShare = "PlugShare"
    case trugo = "Trugo"
    case zes = "Zes"
    case enYakit = "EnYakıt"
    case hizzlan = "Hizzlan"
    case qCharge = "QCharge"
    case voltla = "VOLTLA"
    case oncharge = "onchage"
}

struct Transaction: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
    let type: TransactionType
}

enum TransactionType {
    case deposit, charge
}

struct Offer: Identifiable {
    let id = UUID()
    let provider: ChargingProvider
    let description: String
    let validUntil: Date
}

struct StatView: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    @State private var stations: [ChargeStation] = [
        ChargeStation(name: "Astor Şarj 1", coordinate: CLLocationCoordinate2D(latitude: 41.0122, longitude: 28.9760), type: .dcFast, provider: .astorSarj),
        ChargeStation(name: "Eşarj 1", coordinate: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784), type: .acNormal, provider: .echarge),
        ChargeStation(name: "OTOJET 1", coordinate: CLLocationCoordinate2D(latitude: 41.0042, longitude: 28.9808), type: .dcFast, provider: .otojet),
        // Diğer istasyonları da benzer şekilde ekleyin
    ]
    
    @State private var selectedTypes: Set<StationType> = Set(StationType.allCases)
    @State private var selectedProviders: Set<ChargingProvider> = Set(ChargingProvider.allCases)
    @State private var showingFilters = false
    @State private var showingOffers = false
    @State private var selectedStation: ChargeStation?
    
    let offers: [Offer] = [
        Offer(provider: .astorSarj, description: "15:30 - 18:00 arası şarj işlemlerinde %20 indirim!", validUntil: Date().addingTimeInterval(86400 * 3)),
        Offer(provider: .echarge, description: "Gece şarjlarında %15 indirim", validUntil: Date().addingTimeInterval(86400 * 5)),
        Offer(provider: .otojet, description: "İlk şarjınızda 50 TL bonus", validUntil: Date().addingTimeInterval(86400 * 7))
    ]
    
    var filteredStations: [ChargeStation] {
        stations.filter { station in
            selectedTypes.contains(station.type) && selectedProviders.contains(station.provider)
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Harita
            NavigationView {
                MapView(region: $region, filteredStations: filteredStations, selectedStation: $selectedStation, showingFilters: $showingFilters, showingOffers: $showingOffers, offers: offers)
                    .navigationTitle("Harita")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: { showingOffers = true }) {
                                Image(systemName: "tag.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.orange)
                            }
                        }
                    }
            }
            .tabItem {
                Label("Harita", systemImage: "map")
            }
            .tag(0)
            
            // Cüzdan
            NavigationView {
                WalletView()
            }
            .tabItem {
                Label("Cüzdan", systemImage: "creditcard")
            }
            .tag(1)
            
            // Geçmiş
            NavigationView {
                HistoryView()
            }
            .tabItem {
                Label("Geçmiş", systemImage: "clock")
            }
            .tag(2)
            
            // Profil
            NavigationView {
                ProfileView()
            }
            .tabItem {
                Label("Profil", systemImage: "person")
            }
            .tag(3)
        }
        .accentColor(.green)
        .sheet(isPresented: $showingFilters) {
            FilterView(selectedTypes: $selectedTypes, selectedProviders: $selectedProviders)
        }
        .sheet(isPresented: $showingOffers) {
            OffersView(offers: offers)
        }
    }
}

import SwiftUI
import MapKit

struct MapView: View {
    @Binding var region: MKCoordinateRegion
    let filteredStations: [ChargeStation]
    @Binding var selectedStation: ChargeStation?
    @Binding var showingFilters: Bool
    @Binding var showingOffers: Bool
    let offers: [Offer]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Map(coordinateRegion: $region, annotationItems: filteredStations) { station in
                MapAnnotation(coordinate: station.coordinate) {
                    Button(action: {
                        selectedStation = station
                    }) {
                        Image(systemName: iconForStationType(station.type))
                            .font(.system(size: 22))
                            .frame(width: 44, height: 44)
                            .background(backgroundColorForStationType(station.type))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .shadow(radius: 3)
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingFilters = true }) {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding()
                }
                .padding(.bottom, 60) // Tab bar'ın yüksekliği kadar boşluk bırakıyoruz
            }
            
            // Tab bar arka planı
            Rectangle()
                .fill(Color(.systemBackground).opacity(0.9))
                .frame(height: 50)
                .edgesIgnoringSafeArea(.bottom)
        }
        .sheet(item: $selectedStation) { station in
            StationDetailView(station: station, offers: offers.filter { $0.provider == station.provider })
        }
        .navigationTitle("Harita")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingOffers = true }) {
                    Image(systemName: "tag.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.orange)
                }
            }
        }
    }
    
    func iconForStationType(_ type: StationType) -> String {
        switch type {
        case .acNormal:
            return "bolt.fill"
        case .dcFast:
            return "bolt.car"
        }
    }
    
    func backgroundColorForStationType(_ type: StationType) -> Color {
        switch type {
        case .acNormal:
            return .blue
        case .dcFast:
            return .orange
        }
    }
}

struct StationDetailView: View {
    let station: ChargeStation
    let offers: [Offer]
    @State private var showingQRScanner = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    iconForType(station.type)
                        .font(.system(size: 40))
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    
                    VStack(alignment: .leading) {
                        Text(station.name)
                            .font(.title2)
                        Text(station.type.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                if !offers.isEmpty {
                    Section(header: Text("Mevcut Fırsatlar").font(.headline)) {
                        ForEach(offers) { offer in
                            OfferCard(offer: offer)
                        }
                    }
                }
                
                Button(action: {
                    showingQRScanner = true
                }) {
                    Text("Şarj İşlemi Başlat")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle(station.name)
        .sheet(isPresented: $showingQRScanner) {
            QRScannerView()
        }
    }
    
    func iconForType(_ type: StationType) -> some View {
        switch type {
        case .acNormal:
            return Image(systemName: "bolt.fill")
                .foregroundColor(.white)
                .background(Color.blue)
        case .dcFast:
            return Image(systemName: "bolt.fill")
                .foregroundColor(.white)
                .background(Color.orange)
        }
    }
}

struct OfferCard: View {
    let offer: Offer
    
    var body: some View {
        HStack(spacing: 15) {
            Image(offer.provider.rawValue)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 3)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(offer.provider.rawValue)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(offer.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.orange)
                    Text("Son \(offer.validUntil, style: .relative) gün")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

struct QRScannerView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("QR Kodu Tarayın")
                .font(.title)
            
            Image(systemName: "qrcode.viewfinder")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .foregroundColor(.blue)
            
            Text("Şarj cihazındaki QR kodu tarayın")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding()
            
            Button("Taramayı İptal Et") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

struct StationDetailView: View {
    let station: ChargeStation
    let offers: [Offer]
    @State private var showingQRScanner = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    iconForType(station.type)
                        .font(.system(size: 40))
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    
                    VStack(alignment: .leading) {
                        Text(station.name)
                            .font(.title2)
                        Text(station.type.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                if !offers.isEmpty {
                    Section(header: Text("Mevcut Fırsatlar").font(.headline)) {
                        ForEach(offers) { offer in
                            OfferCard(offer: offer)
                        }
                    }
                }
                
                Button(action: {
                    showingQRScanner = true
                }) {
                    Text("Şarj İşlemi Başlat")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle(station.name)
        .sheet(isPresented: $showingQRScanner) {
            QRScannerView()
        }
    }
    
    func iconForType(_ type: StationType) -> some View {
        switch type {
        case .acNormal:
            return Image(systemName: "bolt.fill")
                .foregroundColor(.white)
                .background(Color.blue)
        case .dcFast:
            return Image(systemName: "bolt.fill")
                .foregroundColor(.white)
                .background(Color.orange)
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            ForEach(0..<4) { index in
                Spacer()
                Button(action: {
                    selectedTab = index
                }) {
                    VStack {
                        Image(systemName: iconName(for: index))
                            .font(.system(size: 24))
                        Text(tabName(for: index))
                            .font(.caption)
                    }
                }
                .foregroundColor(selectedTab == index ? .green : .gray)
                Spacer()
            }
        }
        .padding(.vertical, 10)
        .background(Color(.systemBackground).opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
        .shadow(radius: 5)
    }
    
    func iconName(for index: Int) -> String {
        switch index {
        case 0: return "map"
        case 1: return "creditcard"
        case 2: return "clock"
        case 3: return "person"
        default: return ""
        }
    }
    
    func tabName(for index: Int) -> String {
        switch index {
        case 0: return "Harita"
        case 1: return "Cüzdan"
        case 2: return "Geçmiş"
        case 3: return "Profil"
        default: return ""
        }
    }
}

struct WalletView: View {
    @State private var mainBalance: Double = 1000.0
    @State private var providerBalances: [ChargingProvider: Double] = [
        .astorSarj: 100.0,
        .echarge: 50.0,
        .otojet: 75.0,
        // Diğer sağlayıcılar için de başlangıç bakiyeleri ekleyin
    ]
    @State private var showingAddFunds = false
    @State private var showingTransfer = false
    @State private var selectedProvider: ChargingProvider?
    @State private var showingQRCode = false
    @State private var showingOffers = false
    
    let offers: [Offer] = [
        Offer(provider: .astorSarj, description: "15:30 - 18:00 arası şarj işlemlerinde %20 indirim!", validUntil: Date().addingTimeInterval(86400 * 3)),
        Offer(provider: .echarge, description: "Gece şarjlarında %15 indirim", validUntil: Date().addingTimeInterval(86400 * 5)),
        Offer(provider: .otojet, description: "İlk şarjınızda 50 TL bonus", validUntil: Date().addingTimeInterval(86400 * 7))
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("cü⚡️dan")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                mainBalanceCard
                quickActions
                offersPreview
                providerBalancesList
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: 
            Button(action: { showingOffers = true }) {
                Image(systemName: "tag.fill")
                    .foregroundColor(.orange)
            }
        )
        .sheet(isPresented: $showingAddFunds) {
            AddFundsView(balance: $mainBalance, showingAddFunds: $showingAddFunds)
        }
        .sheet(isPresented: $showingTransfer) {
            if let provider = selectedProvider {
                TransferView(
                    provider: provider,
                    mainBalance: $mainBalance,
                    providerBalance: Binding(
                        get: { providerBalances[provider, default: 0] },
                        set: { providerBalances[provider] = $0 }
                    ),
                    showingTransfer: $showingTransfer
                )
            }
        }
        .sheet(isPresented: $showingQRCode) {
            QRCodeView(balance: mainBalance)
        }
        .sheet(isPresented: $showingOffers) {
            OffersView(offers: offers)
        }
    }
    
    var mainBalanceCard: some View {
        VStack {
            Text("Ana Bakiye")
                .font(.headline)
                .foregroundColor(.white)
            Text(mainBalance, format: .currency(code: "TRY"))
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)
            HStack {
                Image(systemName: "bolt.fill")
                Text("Şarj Edilebilir")
            }
            .font(.caption)
            .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(20)
        .shadow(radius: 10)
    }
    
    var quickActions: some View {
        HStack {
            QuickActionButton(title: "Yükle", icon: "plus", color: .green) {
                showingAddFunds = true
            }
            QuickActionButton(title: "Transfer", icon: "arrow.left.arrow.right", color: .blue) {
                showingTransfer = true
            }
            QuickActionButton(title: "QR Kod", icon: "qrcode", color: .orange) {
                showingQRCode = true
            }
        }
    }
    
    var providerBalancesList: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Sağlayıcı Bakiyeleri")
                .font(.headline)
            
            ForEach(ChargingProvider.allCases, id: \.self) { provider in
                ProviderBalanceRow(provider: provider, balance: providerBalances[provider, default: 0]) {
                    selectedProvider = provider
                    showingTransfer = true
                }
            }
        }
    }
    
    var offersPreview: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Güncel Fırsatlar")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Button(action: { showingOffers = true }) {
                    Text("Tümünü Gör")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(offers) { offer in
                        OfferCard(offer: offer)
                            .frame(width: 280, height: 150)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(color)
            .cornerRadius(10)
        }
    }
}

struct ProviderBalanceRow: View {
    let provider: ChargingProvider
    let balance: Double
    let action: () -> Void
    
    var body: some View {
        HStack {
            Image(provider.rawValue)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(provider.rawValue)
                    .font(.subheadline)
                Text(balance, format: .currency(code: "TRY"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: action) {
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 5)
    }
}

struct QRCodeView: View {
    let balance: Double
    
    var body: some View {
        VStack {
            Image(systemName: "qrcode")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            
            Text("Bakiye: \(balance, format: .currency(code: "TRY"))")
                .font(.headline)
                .padding()
            
            Text("Bu QR kodu kullanarak ödeme yapabilirsiniz.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding()
        }
        .navigationTitle("QR Kod")
    }
}

struct MainCardView: View {
    @Binding var balance: Double
    let action: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Ana Bakiye")
                        .font(.headline)
                    Text(balance, format: .currency(code: "TRY"))
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                Button(action: action) {
                    Text("Yükle")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .cornerRadius(15)
            .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 5)
        }
    }
}

struct WalletCardView: View {
    let provider: ChargingProvider
    let balance: Double
    let action: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Image(provider.rawValue)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 3)
                
                VStack(alignment: .leading) {
                    Text(provider.rawValue)
                        .font(.headline)
                    Text(balance, format: .currency(code: "TRY"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: action) {
                    Text("Transfer")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 5)
        }
    }
}

struct AddFundsView: View {
    @Binding var balance: Double
    @Binding var showingAddFunds: Bool
    @State private var amountToAdd: Double = 0
    @State private var selectedPaymentMethod: PaymentMethod = .creditCard
    
    enum PaymentMethod: String, CaseIterable {
        case creditCard = "Kredi Kartı"
        case bankTransfer = "Banka Transferi"
        case applePay = "Apple Pay"
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ödeme Yöntemi")) {
                    Picker("Ödeme Yöntemi", selection: $selectedPaymentMethod) {
                        ForEach(PaymentMethod.allCases, id: \.self) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Yüklenecek Miktar")) {
                    TextField("Miktar", value: $amountToAdd, format: .currency(code: "TRY"))
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Hızlı Yükleme")) {
                    HStack {
                        ForEach([50.0, 100.0, 200.0], id: \.self) { amount in
                            Button(action: {
                                amountToAdd = amount
                            }) {
                                Text("₺\(Int(amount))")
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                Section {
                    Button("Bakiye Yükle") {
                        balance += amountToAdd
                        showingAddFunds = false
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                }
            }
            .navigationTitle("Bakiye Yükle")
            .navigationBarItems(trailing: Button("İptal") {
                showingAddFunds = false
            })
        }
    }
}

struct TransferView: View {
    let provider: ChargingProvider
    @Binding var mainBalance: Double
    @Binding var providerBalance: Double
    @Binding var showingTransfer: Bool
    @State private var amountToTransfer: Double = 0
    @State private var transferDirection: TransferDirection = .toProvider
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    enum TransferDirection: String, CaseIterable {
        case toProvider = "Ana Bakiyeden Sağlayıcıya"
        case toMain = "Sağlayıcıdan Ana Bakiyeye"
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Transfer Yönü")) {
                    Picker("Transfer Yönü", selection: $transferDirection) {
                        Text("Ana Bakiyeden Sağlayıcıya").tag(TransferDirection.toProvider)
                        Text("Sağlayıcıdan Ana Bakiyeye").tag(TransferDirection.toMain)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Mevcut Bakiyeler")) {
                    HStack {
                        Text("Ana Bakiye:")
                        Spacer()
                        Text(formatCurrency(mainBalance))
                            .foregroundColor(.blue)
                    }
                    HStack {
                        Text("\(provider.rawValue) Bakiye:")
                        Spacer()
                        Text(formatCurrency(providerBalance))
                            .foregroundColor(.green)
                    }
                }
                
                Section(header: Text("Transfer Miktarı")) {
                    TextField("Miktar", value: $amountToTransfer, format: .currency(code: "TRY"))
                        .keyboardType(.decimalPad)
                    
                    HStack {
                        ForEach([10.0, 50.0, 100.0], id: \.self) { amount in
                            Button(action: {
                                amountToTransfer = amount
                            }) {
                                Text("₺\(Int(amount))")
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                Section {
                    Button("Transfer Et") {
                        performTransfer()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
            }
            .navigationTitle("Transfer: \(provider.rawValue)")
            .navigationBarItems(trailing: Button("İptal") {
                showingTransfer = false
            })
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Transfer Bilgisi"), message: Text(alertMessage), dismissButton: .default(Text("Tamam")))
            }
        }
    }
    
    private func performTransfer() {
        switch transferDirection {
        case .toProvider:
            if amountToTransfer <= mainBalance {
                mainBalance -= amountToTransfer
                providerBalance += amountToTransfer
                alertMessage = "\(formatCurrency(amountToTransfer)) başarıyla \(provider.rawValue) hesabınıza transfer edildi."
                showingAlert = true
            } else {
                alertMessage = "Yetersiz bakiye. Lütfen daha düşük bir miktar girin."
                showingAlert = true
            }
        case .toMain:
            if amountToTransfer <= providerBalance {
                providerBalance -= amountToTransfer
                mainBalance += amountToTransfer
                alertMessage = "\(formatCurrency(amountToTransfer)) başarıyla ana hesabınıza transfer edildi."
                showingAlert = true
            } else {
                alertMessage = "Yetersiz bakiye. Lütfen daha düşük bir miktar girin."
                showingAlert = true
            }
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "TRY"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: NSNumber(value: value)) ?? "₺0.00"
    }
}

struct FilterView: View {
    @Binding var selectedTypes: Set<StationType>
    @Binding var selectedProviders: Set<ChargingProvider>
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Şarj Tipi")) {
                    ForEach(StationType.allCases, id: \.self) { type in
                        Toggle(isOn: Binding(
                            get: { selectedTypes.contains(type) },
                            set: { isSelected in
                                if isSelected {
                                    selectedTypes.insert(type)
                                } else {
                                    selectedTypes.remove(type)
                                }
                            }
                        )) {
                            HStack {
                                Image(systemName: iconForType(type))
                                    .foregroundColor(colorForType(type))
                                Text(type.rawValue)
                            }
                        }
                    }
                }
                
                Section(header: Text("Şarj Sağlayıcı")) {
                    ForEach(ChargingProvider.allCases, id: \.self) { provider in
                        Toggle(isOn: Binding(
                            get: { selectedProviders.contains(provider) },
                            set: { isSelected in
                                if isSelected {
                                    selectedProviders.insert(provider)
                                } else {
                                    selectedProviders.remove(provider)
                                }
                            }
                        )) {
                            HStack {
                                Image(provider.rawValue)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                Text(provider.rawValue)
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Filtreler")
            .navigationBarItems(trailing: Button("Uygula") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    func iconForType(_ type: StationType) -> String {
        switch type {
        case .acNormal:
            return "bolt.fill"
        case .dcFast:
            return "bolt.car"
        }
    }
    
    func colorForType(_ type: StationType) -> Color {
        switch type {
        case .acNormal:
            return .blue
        case .dcFast:
            return .orange
        }
    }
}

struct QuickActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 5)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut, value: configuration.isPressed)
    }
}

struct HistoryView: View {
    @State private var chargeHistory: [ChargeHistoryItem] = [
        ChargeHistoryItem(date: Date().addingTimeInterval(-86400 * 2), kWh: 20, duration: 3600, stationName: "Hızlı Şarj 1", cost: 50, provider: .astorSarj),
        ChargeHistoryItem(date: Date().addingTimeInterval(-86400), kWh: 15, duration: 2700, stationName: "Normal Şarj 1", cost: 35, provider: .echarge),
        ChargeHistoryItem(date: Date(), kWh: 10, duration: 1800, stationName: "Yavaş Şarj 1", cost: 20, provider: .otojet)
    ]
    @State private var selectedTimeRange: TimeRange = .week
    @State private var showingFilterOptions = false
    
    enum TimeRange: String, CaseIterable {
        case week = "Son 7 Gün"
        case month = "Son 30 Gün"
        case year = "Son 1 Yıl"
        case all = "Tümü"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    statisticsCard
                    
                    chartView
                    
                    historyList
                }
                .padding()
            }
            .navigationTitle("Şarj Geçmişi")
            .navigationBarItems(
                leading: Button(action: { showingFilterOptions = true }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(.blue)
                },
                trailing: Menu {
                    Picker("Zaman Aralığı", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                } label: {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                }
            )
            .sheet(isPresented: $showingFilterOptions) {
                FilterOptionsView(selectedTimeRange: $selectedTimeRange)
            }
        }
    }
    
    var statisticsCard: some View {
        VStack(spacing: 15) {
            HStack {
                StatView(title: "Toplam kWh", value: String(format: "%.1f", totalKWh), icon: "bolt.fill")
                Divider()
                StatView(title: "Toplam Maliyet", value: String(format: "%.2f TL", totalCost), icon: "turkishlirasign.circle.fill")
            }
            HStack {
                StatView(title: "Ortalama Süre", value: formatDuration(averageDuration), icon: "clock.fill")
                Divider()
                StatView(title: "Şarj Sayısı", value: "\(chargeHistory.count)", icon: "battery.100.bolt")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 5)
    }
    
    var chartView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Şarj İstatistikleri")
                .font(.headline)
            
            Chart {
                ForEach(chargeHistory.sorted { $0.date < $1.date }) { item in
                    BarMark(
                        x: .value("Tarih", item.date, unit: .day),
                        y: .value("kWh", item.kWh)
                    )
                    .foregroundStyle(by: .value("Sağlayıcı", item.provider.rawValue))
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.day().month(), anchor: .top)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 5)
    }
    
    var historyList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Son Şarj İşlemleri")
                .font(.headline)
            
            ForEach(chargeHistory.sorted(by: { $0.date > $1.date })) { item in
                ChargeHistoryItemView(item: item)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 5)
    }
    
    var totalKWh: Double {
        chargeHistory.reduce(0) { $0 + $1.kWh }
    }
    
    var totalCost: Double {
        chargeHistory.reduce(0) { $0 + $1.cost }
    }
    
    var averageDuration: TimeInterval {
        chargeHistory.reduce(0) { $0 + $1.duration } / Double(chargeHistory.count)
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? ""
    }
}

struct ChargeHistoryItem: Identifiable {
    let id = UUID()
    let date: Date
    let kWh: Double
    let duration: TimeInterval
    let stationName: String
    let cost: Double
    let provider: ChargingProvider
}

struct ChargeHistoryItemView: View {
    let item: ChargeHistoryItem
    
    var body: some View {
        HStack {
            Image(item.provider.rawValue)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.stationName)
                    .font(.headline)
                Text(item.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(item.kWh, specifier: "%.1f") kWh")
                    .font(.subheadline)
                Text("\(item.cost, specifier: "%.2f") TL")
                    .font(.headline)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct FilterOptionsView: View {
    @Binding var selectedTimeRange: HistoryView.TimeRange
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Zaman Aralığı")) {
                    Picker("Zaman Aralığı", selection: $selectedTimeRange) {
                        ForEach(HistoryView.TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Buraya ek filtre seçenekleri eklenebilir (örneğin, sağlayıcıya göre filtreleme)
            }
            .navigationTitle("Filtre Seçenekleri")
            .navigationBarItems(trailing: Button("Tamam") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct ProfileView: View {
    @State private var isEditingProfile = false
    @State private var showingLogoutAlert = false
    @State private var showingImagePicker = false
    @State private var userName = "Günebakan Şimşek"
    @State private var userEmail = "elektrobakan@kifobu.com"
    @State private var carBrand = "Tesla"
    @State private var carModel = "Model 3"
    @State private var carPlate = "34 ABC 123"
    @State private var profileImage = UIImage(systemName: "person.circle.fill")!
    @State private var selectedTheme: ColorTheme = .system
    @State private var notificationsEnabled = true
    
    enum ColorTheme: String, CaseIterable {
        case system = "Sistem"
        case light = "Açık"
        case dark = "Koyu"
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                            .onTapGesture {
                                showingImagePicker = true
                            }
                        
                        VStack(alignment: .leading) {
                            Text(userName)
                                .font(.title2)
                            Text(userEmail)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical)
                }
                
                Section(header: Text("Kişisel Bilgiler")) {
                    if isEditingProfile {
                        TextField("Ad Soyad", text: $userName)
                        TextField("E-posta", text: $userEmail)
                    } else {
                        Text("Ad: \(userName)")
                        Text("E-posta: \(userEmail)")
                    }
                }
                
                Section(header: Text("Araç Bilgileri")) {
                    if isEditingProfile {
                        TextField("Marka", text: $carBrand)
                        TextField("Model", text: $carModel)
                        TextField("Plaka", text: $carPlate)
                    } else {
                        Text("Marka: \(carBrand)")
                        Text("Model: \(carModel)")
                        Text("Plaka: \(carPlate)")
                    }
                }
                
                Section(header: Text("Uygulama Ayarları")) {
                    Picker("Tema", selection: $selectedTheme) {
                        ForEach(ColorTheme.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    Toggle("Bildirimleri Etkinleştir", isOn: $notificationsEnabled)
                }
                
                Section {
                    Button(action: {
                        isEditingProfile.toggle()
                    }) {
                        Text(isEditingProfile ? "Değişiklikleri Kaydet" : "Profili Düzenle")
                    }
                    .foregroundColor(.blue)
                }
                
                Section {
                    Button("Çıkış Yap") {
                        showingLogoutAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Profil")
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $profileImage)
            }
            .alert(isPresented: $showingLogoutAlert) {
                Alert(
                    title: Text("Çıkış Yap"),
                    message: Text("Çıkış yapmak istediğinizden emin misiniz?"),
                    primaryButton: .destructive(Text("Çıkış Yap")) {
                        // Çıkış yapma işlemi
                    },
                    secondaryButton: .cancel(Text("İptal"))
                )
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct OfferCard: View {
    let offer: Offer
    
    var body: some View {
        HStack(spacing: 15) {
            Image(offer.provider.rawValue)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 3)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(offer.provider.rawValue)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(offer.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.orange)
                    Text("Son \(offer.validUntil, style: .relative) gün")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

struct OffersView: View {
    let offers: [Offer]
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedOffer: Offer?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(offers) { offer in
                    OfferRowView(offer: offer)
                        .onTapGesture {
                            selectedOffer = offer
                        }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Fırsatlar")
            .navigationBarItems(trailing: Button("Kapat") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .sheet(item: $selectedOffer) { offer in
            OfferDetailView(offer: offer)
        }
    }
}

struct OfferRowView: View {
    let offer: Offer
    
    var body: some View {
        HStack(spacing: 15) {
            Image(offer.provider.rawValue)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 3)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(offer.provider.rawValue)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(offer.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.orange)
                    Text(remainingTimeString(for: offer.validUntil))
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
    
    func remainingTimeString(for date: Date) -> String {
        let remaining = Calendar.current.dateComponents([.day, .hour], from: Date(), to: date)
        if let days = remaining.day, days > 0 {
            return "Son \(days) gün"
        } else if let hours = remaining.hour, hours > 0 {
            return "Son \(hours) saat"
        } else {
            return "Sona eriyor"
        }
    }
}

struct OfferDetailView: View {
    let offer: Offer
    @Environment(\.presentationMode) var presentationMode
    @State private var isOfferUsed = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(offer.provider.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                    
                    VStack(alignment: .leading) {
                        Text(offer.provider.rawValue)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Özel Fırsat")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading)
                }
                
                Text(offer.description)
                    .font(.title3)
                    .fontWeight(.medium)
                
                VStack(alignment: .leading, spacing: 10) {
                    Label("Geçerlilik Başlangıcı: \(formattedDate(offer.validUntil.addingTimeInterval(-86400 * 7)))", systemImage: "calendar")
                    Label("Geçerlilik Bitişi: \(formattedDate(offer.validUntil))", systemImage: "calendar.badge.clock")
                    Label("Kalan Süre: \(remainingTimeString(for: offer.validUntil))", systemImage: "clock")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                if !isOfferUsed {
                    Button(action: {
                        isOfferUsed = true
                    }) {
                        Text("Fırsatı Kullan")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                } else {
                    Text("Bu fırsat kullanıldı")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.secondary)
                        .cornerRadius(10)
                }
                
                Text("Fırsat Koşulları:")
                    .font(.headline)
                    .padding(.top)
                
                Text("Bu fırsat, belirtilen tarihler arasında geçerlidir. Diğer indirimler veya kampanyalarla birleştirilemez. \(offer.provider.rawValue) bu fırsatı değiştirme veya sonlandırma hakkını saklı tutar.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationBarTitle("Fırsat Detayı", displayMode: .inline)
        .navigationBarItems(trailing: Button("Kapat") {
            presentationMode.wrappedValue.dismiss()
        })
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func remainingTimeString(for date: Date) -> String {
        let remaining = Calendar.current.dateComponents([.day, .hour], from: Date(), to: date)
        if let days = remaining.day, days > 0 {
            return "\(days) gün"
        } else if let hours = remaining.hour, hours > 0 {
            return "\(hours) saat"
        } else {
            return "Sona eriyor"
        }
    }
}

// QRScannerView ekleyelim (bu sadece bir örnek, gerçek QR tarama işlevselliği için ek kütüphaneler gerekebilir)
struct QRScannerView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("QR Kodu Tarayın")
                .font(.title)
            
            Image(systemName: "qrcode.viewfinder")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .foregroundColor(.blue)
            
            Text("Şarj cihazındaki QR kodu tarayın")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding()
            
            Button("Taramayı İptal Et") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

// Preview kodu
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
