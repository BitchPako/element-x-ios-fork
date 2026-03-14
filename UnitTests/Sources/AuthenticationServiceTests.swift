//
// Copyright 2025 Element Creations Ltd.
// Copyright 2024-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

@testable import ElementX
import Foundation
import MatrixRustSDKMocks
import Testing

@MainActor
struct AuthenticationServiceTests {
    var client: ClientSDKMock!
    var userSessionStore: UserSessionStoreMock!
    var encryptionKeyProvider: MockEncryptionKeyProvider!
    var service: AuthenticationService!
    
    @Test
    mutating func passwordLogin() async {
        setup()
        
        switch await service.configure(for: "example.com", flow: .login) {
        case .success:
            break
        case .failure(let error):
            Issue.record("Unexpected failure: \(error)")
        }
        
        #expect(service.flow == .login)
        #expect(service.homeserver.value.address == "matrix.bridgemsg.ru")
        
        switch await service.login(username: "alice", password: "12345678", initialDeviceName: nil, deviceID: nil) {
        case .success:
            #expect(client.loginUsernamePasswordInitialDeviceNameDeviceIdCallsCount == 1)
            #expect(userSessionStore.userSessionForSessionDirectoriesPassphraseCallsCount == 1)
            #expect(userSessionStore.userSessionForSessionDirectoriesPassphraseReceivedArguments?.passphrase ==
                encryptionKeyProvider.generateKey().base64EncodedString())
        case .failure(let error):
            Issue.record("Unexpected failure: \(error)")
        }
    }
    
    @Test
    mutating func configureLoginWithOIDC() async {
        setup()
        
        switch await service.configure(for: "matrix.org", flow: .login) {
        case .success:
            break
        case .failure(let error):
            Issue.record("Unexpected failure: \(error)")
        }
        
        #expect(service.flow == .login)
        #expect(service.homeserver.value.address == "matrix.bridgemsg.ru")
    }
    
    @Test
    mutating func configureRegisterWithOIDC() async {
        setup()
        
        switch await service.configure(for: "matrix.org", flow: .register) {
        case .success:
            break
        case .failure(let error):
            Issue.record("Unexpected failure: \(error)")
        }
        
        #expect(service.flow == .register)
        #expect(service.homeserver.value.address == "matrix.bridgemsg.ru")
    }
    
    @Test
    @MainActor
    mutating func configureRegisterNoSupport() async {
        let homeserverAddress = "example.com"
        setup()
        
        switch await service.configure(for: homeserverAddress, flow: .register) {
        case .success:
            Issue.record("Configuration should have failed")
        case .failure(let error):
            #expect(error == .registrationNotSupported)
        }
        
        #expect(service.flow == .login)
        #expect(service.homeserver.value == .init(address: "matrix.bridgemsg.ru", loginMode: .unknown))
    }
    
    // MARK: - Helpers
    
    private mutating func setup() {
        var configuration: AuthenticationClientFactoryMock.Configuration = .init()
        configuration.homeserverClients["matrix.bridgemsg.ru"] = ClientSDKMock(configuration: .init(serverAddress: "matrix.bridgemsg.ru",
                                                                                                             homeserverURL: "https://matrix.bridgemsg.ru",
                                                                                                             slidingSyncVersion: .native,
                                                                                                             oidcLoginURL: "https://auth.matrix.bridgemsg.ru/oidc",
                                                                                                             supportsOIDCCreatePrompt: false,
                                                                                                             supportsPasswordLogin: true))
        let clientFactory = AuthenticationClientFactoryMock(configuration: configuration)
        
        client = configuration.homeserverClients["matrix.bridgemsg.ru"]
        userSessionStore = UserSessionStoreMock(configuration: .init())
        encryptionKeyProvider = MockEncryptionKeyProvider()
        
        service = AuthenticationService(userSessionStore: userSessionStore,
                                        encryptionKeyProvider: encryptionKeyProvider,
                                        classicAppManager: nil,
                                        clientFactory: clientFactory,
                                        appSettings: ServiceLocator.shared.settings,
                                        appHooks: AppHooks())
    }
}

struct MockEncryptionKeyProvider: EncryptionKeyProviderProtocol {
    private let key = "12345678"
    
    func generateKey() -> Data {
        Data(key.utf8)
    }
}
