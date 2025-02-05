// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum Strings {
  public enum Alerts {
    public enum Community {
      /// No, thanks
      public static let dismiss = Strings.tr("Localizable", "alerts.community.dismiss", fallback: "No, thanks")
      /// Did you know that %@ has a subreddit? Subscribe for updates or to discuss issues, features, new platforms or whatever you like.
      /// 
      /// It's also a great way to show you care about this project.
      public static func message(_ p1: Any) -> String {
        return Strings.tr("Localizable", "alerts.community.message", String(describing: p1), fallback: "Did you know that %@ has a subreddit? Subscribe for updates or to discuss issues, features, new platforms or whatever you like.\n\nIt's also a great way to show you care about this project.")
      }
      /// Subscribe now
      public static let subscribe = Strings.tr("Localizable", "alerts.community.subscribe", fallback: "Subscribe now")
    }
    public enum Import {
      public enum Passphrase {
        /// Enter passphrase for '%@'.
        public static func message(_ p1: Any) -> String {
          return Strings.tr("Localizable", "alerts.import.passphrase.message", String(describing: p1), fallback: "Enter passphrase for '%@'.")
        }
        /// Decrypt
        public static let ok = Strings.tr("Localizable", "alerts.import.passphrase.ok", fallback: "Decrypt")
      }
    }
    public enum Providers {
      public enum MissingServer {
        /// No provider server selected. Please select a destination server on your iOS/macOS device.
        public static let message = Strings.tr("Localizable", "alerts.providers.missing_server.message", fallback: "No provider server selected. Please select a destination server on your iOS/macOS device.")
      }
    }
  }
  public enum Entities {
    public enum Dns {
      /// Search domains
      public static let searchDomains = Strings.tr("Localizable", "entities.dns.search_domains", fallback: "Search domains")
      /// Servers
      public static let servers = Strings.tr("Localizable", "entities.dns.servers", fallback: "Servers")
    }
    public enum DnsProtocol {
      /// Cleartext
      public static let cleartext = Strings.tr("Localizable", "entities.dns_protocol.cleartext", fallback: "Cleartext")
      /// Over HTTPS
      public static let https = Strings.tr("Localizable", "entities.dns_protocol.https", fallback: "Over HTTPS")
      /// Over TLS
      public static let tls = Strings.tr("Localizable", "entities.dns_protocol.tls", fallback: "Over TLS")
    }
    public enum HttpProxy {
      /// Bypass domains
      public static let bypassDomains = Strings.tr("Localizable", "entities.http_proxy.bypass_domains", fallback: "Bypass domains")
    }
    public enum OnDemand {
      public enum Policy {
        /// All networks
        public static let any = Strings.tr("Localizable", "entities.on_demand.policy.any", fallback: "All networks")
        /// Excluding
        public static let excluding = Strings.tr("Localizable", "entities.on_demand.policy.excluding", fallback: "Excluding")
        /// Including
        public static let including = Strings.tr("Localizable", "entities.on_demand.policy.including", fallback: "Including")
      }
    }
    public enum Openvpn {
      public enum CompressionAlgorithm {
        /// Unsupported
        public static let other = Strings.tr("Localizable", "entities.openvpn.compression_algorithm.other", fallback: "Unsupported")
      }
      public enum OtpMethod {
        /// Append
        public static let append = Strings.tr("Localizable", "entities.openvpn.otp_method.append", fallback: "Append")
        /// Encode
        public static let encode = Strings.tr("Localizable", "entities.openvpn.otp_method.encode", fallback: "Encode")
        /// None
        public static let `none` = Strings.tr("Localizable", "entities.openvpn.otp_method.none", fallback: "None")
      }
    }
    public enum TunnelStatus {
      /// Activating
      public static let activating = Strings.tr("Localizable", "entities.tunnel_status.activating", fallback: "Activating")
      /// Active
      public static let active = Strings.tr("Localizable", "entities.tunnel_status.active", fallback: "Active")
      /// Deactivating
      public static let deactivating = Strings.tr("Localizable", "entities.tunnel_status.deactivating", fallback: "Deactivating")
      /// Inactive
      public static let inactive = Strings.tr("Localizable", "entities.tunnel_status.inactive", fallback: "Inactive")
    }
  }
  public enum Errors {
    public enum App {
      /// Unable to complete operation.
      public static let `default` = Strings.tr("Localizable", "errors.app.default", fallback: "Unable to complete operation.")
      /// Unable to duplicate profile '%@'.
      public static func duplicate(_ p1: Any) -> String {
        return Strings.tr("Localizable", "errors.app.duplicate", String(describing: p1), fallback: "Unable to duplicate profile '%@'.")
      }
      /// Unable to fetch products, please retry later.
      public static let emptyProducts = Strings.tr("Localizable", "errors.app.empty_products", fallback: "Unable to fetch products, please retry later.")
      /// Profile name is empty.
      public static let emptyProfileName = Strings.tr("Localizable", "errors.app.empty_profile_name", fallback: "Profile name is empty.")
      /// Unable to import profiles.
      public static let `import` = Strings.tr("Localizable", "errors.app.import", fallback: "Unable to import profiles.")
      /// Module %@ is malformed. %@
      public static func malformedModule(_ p1: Any, _ p2: Any) -> String {
        return Strings.tr("Localizable", "errors.app.malformed_module", String(describing: p1), String(describing: p2), fallback: "Module %@ is malformed. %@")
      }
      /// Permission denied
      public static let permissionDenied = Strings.tr("Localizable", "errors.app.permission_denied", fallback: "Permission denied")
      /// Unable to execute operation.
      public static let tunnel = Strings.tr("Localizable", "errors.app.tunnel", fallback: "Unable to execute operation.")
      public enum Passepartout {
        /// Routing module can only be enabled together with a connection.
        public static let connectionModuleRequired = Strings.tr("Localizable", "errors.app.passepartout.connection_module_required", fallback: "Routing module can only be enabled together with a connection.")
        /// Unable to connect to provider server (reason=%@).
        public static func corruptProviderModule(_ p1: Any) -> String {
          return Strings.tr("Localizable", "errors.app.passepartout.corrupt_provider_module", String(describing: p1), fallback: "Unable to connect to provider server (reason=%@).")
        }
        /// Unable to complete operation (code=%@).
        public static func `default`(_ p1: Any) -> String {
          return Strings.tr("Localizable", "errors.app.passepartout.default", String(describing: p1), fallback: "Unable to complete operation (code=%@).")
        }
        /// Some active modules are incompatible, try to only activate one of them.
        public static let incompatibleModules = Strings.tr("Localizable", "errors.app.passepartout.incompatible_modules", fallback: "Some active modules are incompatible, try to only activate one of them.")
        /// Invalid fields.
        public static let invalidFields = Strings.tr("Localizable", "errors.app.passepartout.invalid_fields", fallback: "Invalid fields.")
        /// No server selected in provider.
        public static let missingProviderEntity = Strings.tr("Localizable", "errors.app.passepartout.missing_provider_entity", fallback: "No server selected in provider.")
        /// The profile has no active modules.
        public static let noActiveModules = Strings.tr("Localizable", "errors.app.passepartout.no_active_modules", fallback: "The profile has no active modules.")
        /// Unable to parse file.
        public static let parsing = Strings.tr("Localizable", "errors.app.passepartout.parsing", fallback: "Unable to parse file.")
        /// No provider selected.
        public static let providerRequired = Strings.tr("Localizable", "errors.app.passepartout.provider_required", fallback: "No provider selected.")
        /// The operation timed out.
        public static let timeout = Strings.tr("Localizable", "errors.app.passepartout.timeout", fallback: "The operation timed out.")
      }
    }
    public enum Tunnel {
      /// Auth failed
      public static let auth = Strings.tr("Localizable", "errors.tunnel.auth", fallback: "Auth failed")
      /// Compression unsupported
      public static let compression = Strings.tr("Localizable", "errors.tunnel.compression", fallback: "Compression unsupported")
      /// DNS failed
      public static let dns = Strings.tr("Localizable", "errors.tunnel.dns", fallback: "DNS failed")
      /// Encryption failed
      public static let encryption = Strings.tr("Localizable", "errors.tunnel.encryption", fallback: "Encryption failed")
      /// Failed
      public static let generic = Strings.tr("Localizable", "errors.tunnel.generic", fallback: "Failed")
      /// Purchase required
      public static let ineligible = Strings.tr("Localizable", "errors.tunnel.ineligible", fallback: "Purchase required")
      /// Missing routing
      public static let routing = Strings.tr("Localizable", "errors.tunnel.routing", fallback: "Missing routing")
      /// Server shutdown
      public static let shutdown = Strings.tr("Localizable", "errors.tunnel.shutdown", fallback: "Server shutdown")
      /// TLS failed
      public static let tls = Strings.tr("Localizable", "errors.tunnel.tls", fallback: "TLS failed")
    }
  }
  public enum Features {
    /// %@
    public static func appletv(_ p1: Any) -> String {
      return Strings.tr("Localizable", "features.appletv", String(describing: p1), fallback: "%@")
    }
    /// DNS Settings
    public static let dns = Strings.tr("Localizable", "features.dns", fallback: "DNS Settings")
    /// HTTP Proxy Settings
    public static let httpProxy = Strings.tr("Localizable", "features.http_proxy", fallback: "HTTP Proxy Settings")
    /// Interactive Login
    public static let interactiveLogin = Strings.tr("Localizable", "features.interactiveLogin", fallback: "Interactive Login")
    /// On-Demand Rules
    public static let onDemand = Strings.tr("Localizable", "features.on_demand", fallback: "On-Demand Rules")
    /// All Providers
    public static let providers = Strings.tr("Localizable", "features.providers", fallback: "All Providers")
    /// Custom Routing
    public static let routing = Strings.tr("Localizable", "features.routing", fallback: "Custom Routing")
    /// %@
    public static func sharing(_ p1: Any) -> String {
      return Strings.tr("Localizable", "features.sharing", String(describing: p1), fallback: "%@")
    }
  }
  public enum Global {
    public enum Actions {
      /// Add
      public static let add = Strings.tr("Localizable", "global.actions.add", fallback: "Add")
      /// Cancel
      public static let cancel = Strings.tr("Localizable", "global.actions.cancel", fallback: "Cancel")
      /// Connect
      public static let connect = Strings.tr("Localizable", "global.actions.connect", fallback: "Connect")
      /// Delete
      public static let delete = Strings.tr("Localizable", "global.actions.delete", fallback: "Delete")
      /// Disable
      public static let disable = Strings.tr("Localizable", "global.actions.disable", fallback: "Disable")
      /// Disconnect
      public static let disconnect = Strings.tr("Localizable", "global.actions.disconnect", fallback: "Disconnect")
      /// Duplicate
      public static let duplicate = Strings.tr("Localizable", "global.actions.duplicate", fallback: "Duplicate")
      /// Edit
      public static let edit = Strings.tr("Localizable", "global.actions.edit", fallback: "Edit")
      /// Enable
      public static let enable = Strings.tr("Localizable", "global.actions.enable", fallback: "Enable")
      /// Hide
      public static let hide = Strings.tr("Localizable", "global.actions.hide", fallback: "Hide")
      /// Purchase
      public static let purchase = Strings.tr("Localizable", "global.actions.purchase", fallback: "Purchase")
      /// Restart
      public static let reconnect = Strings.tr("Localizable", "global.actions.reconnect", fallback: "Restart")
      /// Delete
      public static let remove = Strings.tr("Localizable", "global.actions.remove", fallback: "Delete")
      /// Save
      public static let save = Strings.tr("Localizable", "global.actions.save", fallback: "Save")
      /// Select
      public static let select = Strings.tr("Localizable", "global.actions.select", fallback: "Select")
      /// Show
      public static let show = Strings.tr("Localizable", "global.actions.show", fallback: "Show")
    }
    public enum Nouns {
      /// About
      public static let about = Strings.tr("Localizable", "global.nouns.about", fallback: "About")
      /// Account
      public static let account = Strings.tr("Localizable", "global.nouns.account", fallback: "Account")
      /// Address
      public static let address = Strings.tr("Localizable", "global.nouns.address", fallback: "Address")
      /// Addresses
      public static let addresses = Strings.tr("Localizable", "global.nouns.addresses", fallback: "Addresses")
      /// Any
      public static let any = Strings.tr("Localizable", "global.nouns.any", fallback: "Any")
      /// Category
      public static let category = Strings.tr("Localizable", "global.nouns.category", fallback: "Category")
      /// Certificate
      public static let certificate = Strings.tr("Localizable", "global.nouns.certificate", fallback: "Certificate")
      /// Compression
      public static let compression = Strings.tr("Localizable", "global.nouns.compression", fallback: "Compression")
      /// Configuration
      public static let configuration = Strings.tr("Localizable", "global.nouns.configuration", fallback: "Configuration")
      /// Connection
      public static let connection = Strings.tr("Localizable", "global.nouns.connection", fallback: "Connection")
      /// Country
      public static let country = Strings.tr("Localizable", "global.nouns.country", fallback: "Country")
      /// Default
      public static let `default` = Strings.tr("Localizable", "global.nouns.default", fallback: "Default")
      /// Destination
      public static let destination = Strings.tr("Localizable", "global.nouns.destination", fallback: "Destination")
      /// Disabled
      public static let disabled = Strings.tr("Localizable", "global.nouns.disabled", fallback: "Disabled")
      /// Don't ask again
      public static let doNotAskAgain = Strings.tr("Localizable", "global.nouns.do_not_ask_again", fallback: "Don't ask again")
      /// Domain
      public static let domain = Strings.tr("Localizable", "global.nouns.domain", fallback: "Domain")
      /// Done
      public static let done = Strings.tr("Localizable", "global.nouns.done", fallback: "Done")
      /// Empty
      public static let empty = Strings.tr("Localizable", "global.nouns.empty", fallback: "Empty")
      /// Enabled
      public static let enabled = Strings.tr("Localizable", "global.nouns.enabled", fallback: "Enabled")
      /// Endpoint
      public static let endpoint = Strings.tr("Localizable", "global.nouns.endpoint", fallback: "Endpoint")
      /// Features
      public static let features = Strings.tr("Localizable", "global.nouns.features", fallback: "Features")
      /// Filters
      public static let filters = Strings.tr("Localizable", "global.nouns.filters", fallback: "Filters")
      /// Folder
      public static let folder = Strings.tr("Localizable", "global.nouns.folder", fallback: "Folder")
      /// Gateway
      public static let gateway = Strings.tr("Localizable", "global.nouns.gateway", fallback: "Gateway")
      /// General
      public static let general = Strings.tr("Localizable", "global.nouns.general", fallback: "General")
      /// Hostname
      public static let hostname = Strings.tr("Localizable", "global.nouns.hostname", fallback: "Hostname")
      /// Interface
      public static let interface = Strings.tr("Localizable", "global.nouns.interface", fallback: "Interface")
      /// Interval
      public static let interval = Strings.tr("Localizable", "global.nouns.interval", fallback: "Interval")
      /// Keep-alive
      public static let keepAlive = Strings.tr("Localizable", "global.nouns.keep_alive", fallback: "Keep-alive")
      /// Key
      public static let key = Strings.tr("Localizable", "global.nouns.key", fallback: "Key")
      /// Last update
      public static let lastUpdate = Strings.tr("Localizable", "global.nouns.last_update", fallback: "Last update")
      /// Loading
      public static let loading = Strings.tr("Localizable", "global.nouns.loading", fallback: "Loading")
      /// Method
      public static let method = Strings.tr("Localizable", "global.nouns.method", fallback: "Method")
      /// Modules
      public static let modules = Strings.tr("Localizable", "global.nouns.modules", fallback: "Modules")
      /// %d seconds
      public static func nSeconds(_ p1: Int) -> String {
        return Strings.tr("Localizable", "global.nouns.n_seconds", p1, fallback: "%d seconds")
      }
      /// Name
      public static let name = Strings.tr("Localizable", "global.nouns.name", fallback: "Name")
      /// Networks
      public static let networks = Strings.tr("Localizable", "global.nouns.networks", fallback: "Networks")
      /// No content
      public static let noContent = Strings.tr("Localizable", "global.nouns.no_content", fallback: "No content")
      /// No selection
      public static let noSelection = Strings.tr("Localizable", "global.nouns.no_selection", fallback: "No selection")
      /// None
      public static let `none` = Strings.tr("Localizable", "global.nouns.none", fallback: "None")
      /// OK
      public static let ok = Strings.tr("Localizable", "global.nouns.ok", fallback: "OK")
      /// On-demand
      public static let onDemand = Strings.tr("Localizable", "global.nouns.on_demand", fallback: "On-demand")
      /// Other
      public static let other = Strings.tr("Localizable", "global.nouns.other", fallback: "Other")
      /// Password
      public static let password = Strings.tr("Localizable", "global.nouns.password", fallback: "Password")
      /// Port
      public static let port = Strings.tr("Localizable", "global.nouns.port", fallback: "Port")
      /// Private key
      public static let privateKey = Strings.tr("Localizable", "global.nouns.private_key", fallback: "Private key")
      /// Products
      public static let products = Strings.tr("Localizable", "global.nouns.products", fallback: "Products")
      /// Profile
      public static let profile = Strings.tr("Localizable", "global.nouns.profile", fallback: "Profile")
      /// Protocol
      public static let `protocol` = Strings.tr("Localizable", "global.nouns.protocol", fallback: "Protocol")
      /// Provider
      public static let provider = Strings.tr("Localizable", "global.nouns.provider", fallback: "Provider")
      /// Public key
      public static let publicKey = Strings.tr("Localizable", "global.nouns.public_key", fallback: "Public key")
      /// Purchases
      public static let purchases = Strings.tr("Localizable", "global.nouns.purchases", fallback: "Purchases")
      /// Region
      public static let region = Strings.tr("Localizable", "global.nouns.region", fallback: "Region")
      /// Route
      public static let route = Strings.tr("Localizable", "global.nouns.route", fallback: "Route")
      /// Routes
      public static let routes = Strings.tr("Localizable", "global.nouns.routes", fallback: "Routes")
      /// Routing
      public static let routing = Strings.tr("Localizable", "global.nouns.routing", fallback: "Routing")
      /// Server
      public static let server = Strings.tr("Localizable", "global.nouns.server", fallback: "Server")
      /// Servers
      public static let servers = Strings.tr("Localizable", "global.nouns.servers", fallback: "Servers")
      /// Settings
      public static let settings = Strings.tr("Localizable", "global.nouns.settings", fallback: "Settings")
      /// Status
      public static let status = Strings.tr("Localizable", "global.nouns.status", fallback: "Status")
      /// Subnet
      public static let subnet = Strings.tr("Localizable", "global.nouns.subnet", fallback: "Subnet")
      /// Timeout
      public static let timeout = Strings.tr("Localizable", "global.nouns.timeout", fallback: "Timeout")
      /// Unknown
      public static let unknown = Strings.tr("Localizable", "global.nouns.unknown", fallback: "Unknown")
      /// Username
      public static let username = Strings.tr("Localizable", "global.nouns.username", fallback: "Username")
      /// Version
      public static let version = Strings.tr("Localizable", "global.nouns.version", fallback: "Version")
    }
  }
  public enum Modules {
    public enum Dns {
      public enum SearchDomains {
        /// Add domain
        public static let add = Strings.tr("Localizable", "modules.dns.search_domains.add", fallback: "Add domain")
      }
      public enum Servers {
        /// Add address
        public static let add = Strings.tr("Localizable", "modules.dns.servers.add", fallback: "Add address")
      }
    }
    public enum General {
      public enum Rows {
        /// %@
        public static func appletv(_ p1: Any) -> String {
          return Strings.tr("Localizable", "modules.general.rows.appletv", String(describing: p1), fallback: "%@")
        }
        /// Import from file
        public static let importFromFile = Strings.tr("Localizable", "modules.general.rows.import_from_file", fallback: "Import from file")
        /// Enabled
        public static let shared = Strings.tr("Localizable", "modules.general.rows.shared", fallback: "Enabled")
        public enum Appletv {
          /// Drop TV restriction
          public static let purchase = Strings.tr("Localizable", "modules.general.rows.appletv.purchase", fallback: "Drop TV restriction")
        }
        public enum Shared {
          /// Share on iCloud
          public static let purchase = Strings.tr("Localizable", "modules.general.rows.shared.purchase", fallback: "Share on iCloud")
        }
      }
      public enum Sections {
        public enum Storage {
          /// Profiles are stored to %@ encrypted.
          public static func footer(_ p1: Any) -> String {
            return Strings.tr("Localizable", "modules.general.sections.storage.footer", String(describing: p1), fallback: "Profiles are stored to %@ encrypted.")
          }
          /// %@
          public static func header(_ p1: Any) -> String {
            return Strings.tr("Localizable", "modules.general.sections.storage.header", String(describing: p1), fallback: "%@")
          }
          public enum Footer {
            public enum Purchase {
              /// TV profiles do not work in beta builds.
              public static let tvBeta = Strings.tr("Localizable", "modules.general.sections.storage.footer.purchase.tv_beta", fallback: "TV profiles do not work in beta builds.")
              /// TV profiles do not work without a purchase.
              public static let tvRelease = Strings.tr("Localizable", "modules.general.sections.storage.footer.purchase.tv_release", fallback: "TV profiles do not work without a purchase.")
            }
          }
        }
      }
    }
    public enum HttpProxy {
      public enum BypassDomains {
        /// Add bypass domain
        public static let add = Strings.tr("Localizable", "modules.http_proxy.bypass_domains.add", fallback: "Add bypass domain")
      }
    }
    public enum Ip {
      public enum Routes {
        /// Add %@
        public static func addFamily(_ p1: Any) -> String {
          return Strings.tr("Localizable", "modules.ip.routes.add_family", String(describing: p1), fallback: "Add %@")
        }
        /// Exclude route
        public static let exclude = Strings.tr("Localizable", "modules.ip.routes.exclude", fallback: "Exclude route")
        /// Excluded routes
        public static let excluded = Strings.tr("Localizable", "modules.ip.routes.excluded", fallback: "Excluded routes")
        /// Include route
        public static let include = Strings.tr("Localizable", "modules.ip.routes.include", fallback: "Include route")
        /// Included routes
        public static let included = Strings.tr("Localizable", "modules.ip.routes.included", fallback: "Included routes")
      }
    }
    public enum OnDemand {
      /// Ethernet
      public static let ethernet = Strings.tr("Localizable", "modules.on_demand.ethernet", fallback: "Ethernet")
      /// Mobile
      public static let mobile = Strings.tr("Localizable", "modules.on_demand.mobile", fallback: "Mobile")
      /// Policy
      public static let policy = Strings.tr("Localizable", "modules.on_demand.policy", fallback: "Policy")
      public enum Networks {
        /// These rules will only apply on devices where the interface type is supported.
        public static let footer = Strings.tr("Localizable", "modules.on_demand.networks.footer", fallback: "These rules will only apply on devices where the interface type is supported.")
      }
      public enum Policy {
        /// Activate the VPN %@.
        public static func footer(_ p1: Any) -> String {
          return Strings.tr("Localizable", "modules.on_demand.policy.footer", String(describing: p1), fallback: "Activate the VPN %@.")
        }
        public enum Footer {
          /// in any network
          public static let any = Strings.tr("Localizable", "modules.on_demand.policy.footer.any", fallback: "in any network")
          /// except in the networks below
          public static let excluding = Strings.tr("Localizable", "modules.on_demand.policy.footer.excluding", fallback: "except in the networks below")
          /// only in the networks below
          public static let including = Strings.tr("Localizable", "modules.on_demand.policy.footer.including", fallback: "only in the networks below")
        }
      }
      public enum Ssid {
        /// Add SSID
        public static let add = Strings.tr("Localizable", "modules.on_demand.ssid.add", fallback: "Add SSID")
      }
    }
    public enum Openvpn {
      /// Cipher
      public static let cipher = Strings.tr("Localizable", "modules.openvpn.cipher", fallback: "Cipher")
      /// Communication
      public static let communication = Strings.tr("Localizable", "modules.openvpn.communication", fallback: "Communication")
      /// Compression
      public static let compression = Strings.tr("Localizable", "modules.openvpn.compression", fallback: "Compression")
      /// Algorithm
      public static let compressionAlgorithm = Strings.tr("Localizable", "modules.openvpn.compression_algorithm", fallback: "Algorithm")
      /// Framing
      public static let compressionFraming = Strings.tr("Localizable", "modules.openvpn.compression_framing", fallback: "Framing")
      /// Credentials
      public static let credentials = Strings.tr("Localizable", "modules.openvpn.credentials", fallback: "Credentials")
      /// Digest
      public static let digest = Strings.tr("Localizable", "modules.openvpn.digest", fallback: "Digest")
      /// Extended verification
      public static let eku = Strings.tr("Localizable", "modules.openvpn.eku", fallback: "Extended verification")
      /// Pull
      public static let pull = Strings.tr("Localizable", "modules.openvpn.pull", fallback: "Pull")
      /// Randomize endpoint
      public static let randomizeEndpoint = Strings.tr("Localizable", "modules.openvpn.randomize_endpoint", fallback: "Randomize endpoint")
      /// Randomize hostname
      public static let randomizeHostname = Strings.tr("Localizable", "modules.openvpn.randomize_hostname", fallback: "Randomize hostname")
      /// Redirect gateway
      public static let redirectGateway = Strings.tr("Localizable", "modules.openvpn.redirect_gateway", fallback: "Redirect gateway")
      /// Remote endpoints
      public static let remotes = Strings.tr("Localizable", "modules.openvpn.remotes", fallback: "Remote endpoints")
      /// Renegotiation
      public static let renegotiation = Strings.tr("Localizable", "modules.openvpn.renegotiation", fallback: "Renegotiation")
      /// Wrapping
      public static let tlsWrap = Strings.tr("Localizable", "modules.openvpn.tls_wrap", fallback: "Wrapping")
      public enum Credentials {
        /// Interactive
        public static let interactive = Strings.tr("Localizable", "modules.openvpn.credentials.interactive", fallback: "Interactive")
        public enum Guidance {
          /// See your OpenVPN credentials
          public static let link = Strings.tr("Localizable", "modules.openvpn.credentials.guidance.link", fallback: "See your OpenVPN credentials")
          /// Use your specific OpenVPN credentials, which are not the same credentials you log in with.
          public static let specific = Strings.tr("Localizable", "modules.openvpn.credentials.guidance.specific", fallback: "Use your specific OpenVPN credentials, which are not the same credentials you log in with.")
          /// Use your login credentials.
          public static let web = Strings.tr("Localizable", "modules.openvpn.credentials.guidance.web", fallback: "Use your login credentials.")
        }
        public enum Interactive {
          /// On-demand will be disabled.
          public static let footer = Strings.tr("Localizable", "modules.openvpn.credentials.interactive.footer", fallback: "On-demand will be disabled.")
        }
        public enum OtpMethod {
          public enum Approach {
            /// The OTP will be appended to the password.
            public static let append = Strings.tr("Localizable", "modules.openvpn.credentials.otp_method.approach.append", fallback: "The OTP will be appended to the password.")
            /// The OTP will be encoded in Base64 with the password.
            public static let encode = Strings.tr("Localizable", "modules.openvpn.credentials.otp_method.approach.encode", fallback: "The OTP will be encoded in Base64 with the password.")
          }
        }
      }
    }
    public enum Wireguard {
      /// Allowed IPs
      public static let allowedIps = Strings.tr("Localizable", "modules.wireguard.allowed_ips", fallback: "Allowed IPs")
      /// Interface
      public static let interface = Strings.tr("Localizable", "modules.wireguard.interface", fallback: "Interface")
      /// Peer #%d
      public static func peer(_ p1: Int) -> String {
        return Strings.tr("Localizable", "modules.wireguard.peer", p1, fallback: "Peer #%d")
      }
      /// Pre-shared key
      public static let presharedKey = Strings.tr("Localizable", "modules.wireguard.preshared_key", fallback: "Pre-shared key")
      /// Private key
      public static let providerKey = Strings.tr("Localizable", "modules.wireguard.provider_key", fallback: "Private key")
    }
  }
  public enum Placeholders {
    /// secret
    public static let secret = Strings.tr("Localizable", "placeholders.secret", fallback: "secret")
    /// username
    public static let username = Strings.tr("Localizable", "placeholders.username", fallback: "username")
    public enum OnDemand {
      /// My SSID
      public static let ssid = Strings.tr("Localizable", "placeholders.on_demand.ssid", fallback: "My SSID")
    }
    public enum Profile {
      /// My profile
      public static let name = Strings.tr("Localizable", "placeholders.profile.name", fallback: "My profile")
    }
  }
  public enum Theme {
    public enum Confirmation {
      /// Cancel
      public static let cancel = Strings.tr("Localizable", "theme.confirmation.cancel", fallback: "Cancel")
      /// Are you sure you want to proceed with this operation?
      public static let message = Strings.tr("Localizable", "theme.confirmation.message", fallback: "Are you sure you want to proceed with this operation?")
      /// Confirm
      public static let ok = Strings.tr("Localizable", "theme.confirmation.ok", fallback: "Confirm")
    }
    public enum LockScreen {
      /// %@ is locked
      public static func reason(_ p1: Any) -> String {
        return Strings.tr("Localizable", "theme.lock_screen.reason", String(describing: p1), fallback: "%@ is locked")
      }
    }
  }
  public enum Views {
    public enum About {
      /// About
      public static let title = Strings.tr("Localizable", "views.about.title", fallback: "About")
      public enum Credits {
        /// Licenses
        public static let licenses = Strings.tr("Localizable", "views.about.credits.licenses", fallback: "Licenses")
        /// Notices
        public static let notices = Strings.tr("Localizable", "views.about.credits.notices", fallback: "Notices")
        /// Credits
        public static let title = Strings.tr("Localizable", "views.about.credits.title", fallback: "Credits")
        /// Translations
        public static let translations = Strings.tr("Localizable", "views.about.credits.translations", fallback: "Translations")
      }
      public enum Links {
        /// Links
        public static let title = Strings.tr("Localizable", "views.about.links.title", fallback: "Links")
        public enum Rows {
          /// Disclaimer
          public static let disclaimer = Strings.tr("Localizable", "views.about.links.rows.disclaimer", fallback: "Disclaimer")
          /// Home page
          public static let homePage = Strings.tr("Localizable", "views.about.links.rows.home_page", fallback: "Home page")
          /// Join community
          public static let joinCommunity = Strings.tr("Localizable", "views.about.links.rows.join_community", fallback: "Join community")
          /// Privacy policy
          public static let privacyPolicy = Strings.tr("Localizable", "views.about.links.rows.privacy_policy", fallback: "Privacy policy")
          /// Write a review
          public static let writeReview = Strings.tr("Localizable", "views.about.links.rows.write_review", fallback: "Write a review")
        }
        public enum Sections {
          /// Support
          public static let support = Strings.tr("Localizable", "views.about.links.sections.support", fallback: "Support")
          /// Web
          public static let web = Strings.tr("Localizable", "views.about.links.sections.web", fallback: "Web")
        }
      }
    }
    public enum App {
      public enum Folders {
        /// My profiles
        public static let `default` = Strings.tr("Localizable", "views.app.folders.default", fallback: "My profiles")
        /// No profiles
        public static let noProfiles = Strings.tr("Localizable", "views.app.folders.no_profiles", fallback: "No profiles")
        public enum NoProfiles {
          /// Migrate old profiles...
          public static let migrate = Strings.tr("Localizable", "views.app.folders.no_profiles.migrate", fallback: "Migrate old profiles...")
        }
      }
      public enum InstalledProfile {
        public enum None {
          /// No profile
          public static let name = Strings.tr("Localizable", "views.app.installed_profile.none.name", fallback: "No profile")
          /// Tap list to connect
          public static let status = Strings.tr("Localizable", "views.app.installed_profile.none.status", fallback: "Tap list to connect")
        }
      }
      public enum Profile {
        /// No active modules
        public static let noModules = Strings.tr("Localizable", "views.app.profile.no_modules", fallback: "No active modules")
      }
      public enum ProfileContext {
        /// Connect to
        public static let connectTo = Strings.tr("Localizable", "views.app.profile_context.connect_to", fallback: "Connect to")
      }
      public enum Toolbar {
        /// Import profile
        public static let importProfile = Strings.tr("Localizable", "views.app.toolbar.import_profile", fallback: "Import profile")
        /// Migrate profiles
        public static let migrateProfiles = Strings.tr("Localizable", "views.app.toolbar.migrate_profiles", fallback: "Migrate profiles")
        public enum NewProfile {
          /// Empty profile
          public static let empty = Strings.tr("Localizable", "views.app.toolbar.new_profile.empty", fallback: "Empty profile")
          /// Provider
          public static let provider = Strings.tr("Localizable", "views.app.toolbar.new_profile.provider", fallback: "Provider")
        }
      }
      public enum Tv {
        /// Open %@ on your iOS or macOS device and enable the "%@" toggle of a profile to make it appear here.
        public static func header(_ p1: Any, _ p2: Any) -> String {
          return Strings.tr("Localizable", "views.app.tv.header", String(describing: p1), String(describing: p2), fallback: "Open %@ on your iOS or macOS device and enable the \"%@\" toggle of a profile to make it appear here.")
        }
      }
    }
    public enum AppMenu {
      public enum Items {
        /// Quit %@
        public static func quit(_ p1: Any) -> String {
          return Strings.tr("Localizable", "views.app_menu.items.quit", String(describing: p1), fallback: "Quit %@")
        }
      }
    }
    public enum Diagnostics {
      /// Diagnostics
      public static let title = Strings.tr("Localizable", "views.diagnostics.title", fallback: "Diagnostics")
      public enum Alerts {
        public enum ReportIssue {
          /// The device is not configured to send e-mails.
          public static let email = Strings.tr("Localizable", "views.diagnostics.alerts.report_issue.email", fallback: "The device is not configured to send e-mails.")
        }
      }
      public enum Openvpn {
        public enum Rows {
          /// Server configuration
          public static let serverConfiguration = Strings.tr("Localizable", "views.diagnostics.openvpn.rows.server_configuration", fallback: "Server configuration")
        }
      }
      public enum ReportIssue {
        /// Report issue
        public static let title = Strings.tr("Localizable", "views.diagnostics.report_issue.title", fallback: "Report issue")
      }
      public enum Rows {
        /// App
        public static let app = Strings.tr("Localizable", "views.diagnostics.rows.app", fallback: "App")
        /// Include private data
        public static let includePrivateData = Strings.tr("Localizable", "views.diagnostics.rows.include_private_data", fallback: "Include private data")
        /// Delete all logs
        public static let removeTunnelLogs = Strings.tr("Localizable", "views.diagnostics.rows.remove_tunnel_logs", fallback: "Delete all logs")
        /// Tunnel
        public static let tunnel = Strings.tr("Localizable", "views.diagnostics.rows.tunnel", fallback: "Tunnel")
      }
      public enum Sections {
        /// Live log
        public static let live = Strings.tr("Localizable", "views.diagnostics.sections.live", fallback: "Live log")
        /// Tunnel logs
        public static let tunnel = Strings.tr("Localizable", "views.diagnostics.sections.tunnel", fallback: "Tunnel logs")
      }
    }
    public enum Donate {
      /// Make a donation
      public static let title = Strings.tr("Localizable", "views.donate.title", fallback: "Make a donation")
      public enum Alerts {
        public enum ThankYou {
          /// This means a lot to me and I really hope you keep using and promoting this app.
          public static let message = Strings.tr("Localizable", "views.donate.alerts.thank_you.message", fallback: "This means a lot to me and I really hope you keep using and promoting this app.")
        }
      }
      public enum Sections {
        public enum Main {
          /// If you want to display gratitude for my work, here are a couple of amounts you can donate instantly. You will only be charged once per donation, and you can donate multiple times.
          public static let footer = Strings.tr("Localizable", "views.donate.sections.main.footer", fallback: "If you want to display gratitude for my work, here are a couple of amounts you can donate instantly. You will only be charged once per donation, and you can donate multiple times.")
        }
      }
    }
    public enum Migration {
      /// Nothing to migrate
      public static let noProfiles = Strings.tr("Localizable", "views.migration.no_profiles", fallback: "Nothing to migrate")
      /// Migrate
      public static let title = Strings.tr("Localizable", "views.migration.title", fallback: "Migrate")
      public enum Alerts {
        public enum Delete {
          /// Do you want to discard these profiles? You will not be able to recover them later.
          /// 
          /// %@
          public static func message(_ p1: Any) -> String {
            return Strings.tr("Localizable", "views.migration.alerts.delete.message", String(describing: p1), fallback: "Do you want to discard these profiles? You will not be able to recover them later.\n\n%@")
          }
        }
      }
      public enum Items {
        /// Discard
        public static let discard = Strings.tr("Localizable", "views.migration.items.discard", fallback: "Discard")
        /// Proceed
        public static let migrate = Strings.tr("Localizable", "views.migration.items.migrate", fallback: "Proceed")
      }
      public enum Sections {
        public enum Main {
          /// Select below the profiles from old versions of %@ that you want to import. In case your profiles are stored on iCloud, they may take a while to synchronize. If you do not see them now, please come back later.
          public static func header(_ p1: Any) -> String {
            return Strings.tr("Localizable", "views.migration.sections.main.header", String(describing: p1), fallback: "Select below the profiles from old versions of %@ that you want to import. In case your profiles are stored on iCloud, they may take a while to synchronize. If you do not see them now, please come back later.")
          }
        }
      }
    }
    public enum Paywall {
      public enum Alerts {
        public enum Confirmation {
          /// This profile requires paid features to work.
          public static let message = Strings.tr("Localizable", "views.paywall.alerts.confirmation.message", fallback: "This profile requires paid features to work.")
          /// Purchase required
          public static let title = Strings.tr("Localizable", "views.paywall.alerts.confirmation.title", fallback: "Purchase required")
          public enum Message {
            /// You may test the connection for %d minutes.
            public static func connect(_ p1: Int) -> String {
              return Strings.tr("Localizable", "views.paywall.alerts.confirmation.message.connect", p1, fallback: "You may test the connection for %d minutes.")
            }
          }
        }
        public enum Pending {
          /// The purchase is pending external confirmation. The feature will be credited upon approval.
          public static let message = Strings.tr("Localizable", "views.paywall.alerts.pending.message", fallback: "The purchase is pending external confirmation. The feature will be credited upon approval.")
        }
        public enum Restricted {
          /// Some features are unavailable in this build.
          public static let message = Strings.tr("Localizable", "views.paywall.alerts.restricted.message", fallback: "Some features are unavailable in this build.")
          /// Restricted
          public static let title = Strings.tr("Localizable", "views.paywall.alerts.restricted.title", fallback: "Restricted")
        }
        public enum Verification {
          /// This may take a little longer if your device was just started.
          public static let boot = Strings.tr("Localizable", "views.paywall.alerts.verification.boot", fallback: "This may take a little longer if your device was just started.")
          /// Please wait while your purchases are being verified.
          public static let edit = Strings.tr("Localizable", "views.paywall.alerts.verification.edit", fallback: "Please wait while your purchases are being verified.")
          public enum Connect {
            /// Your purchases are being verified.
            public static let _1 = Strings.tr("Localizable", "views.paywall.alerts.verification.connect.1", fallback: "Your purchases are being verified.")
            /// If verification cannot be completed, the connection will end in %d minutes.
            public static func _2(_ p1: Int) -> String {
              return Strings.tr("Localizable", "views.paywall.alerts.verification.connect.2", p1, fallback: "If verification cannot be completed, the connection will end in %d minutes.")
            }
          }
        }
      }
      public enum Rows {
        /// Restore purchases
        public static let restorePurchases = Strings.tr("Localizable", "views.paywall.rows.restore_purchases", fallback: "Restore purchases")
      }
      public enum Sections {
        public enum AllFeatures {
          /// Full version includes
          public static let header = Strings.tr("Localizable", "views.paywall.sections.all_features.header", fallback: "Full version includes")
        }
        public enum FullProducts {
          /// Full version
          public static let header = Strings.tr("Localizable", "views.paywall.sections.full_products.header", fallback: "Full version")
        }
        public enum Products {
          /// All purchases support Family Sharing.
          public static let footer = Strings.tr("Localizable", "views.paywall.sections.products.footer", fallback: "All purchases support Family Sharing.")
        }
        public enum RequiredFeatures {
          /// Required features
          public static let header = Strings.tr("Localizable", "views.paywall.sections.required_features.header", fallback: "Required features")
        }
        public enum Restore {
          /// If you bought this app or feature in the past, you can restore your purchases.
          public static let footer = Strings.tr("Localizable", "views.paywall.sections.restore.footer", fallback: "If you bought this app or feature in the past, you can restore your purchases.")
          /// Restore
          public static let header = Strings.tr("Localizable", "views.paywall.sections.restore.header", fallback: "Restore")
        }
      }
    }
    public enum Preferences {
      /// Erase profiles from iCloud
      public static let eraseIcloud = Strings.tr("Localizable", "views.preferences.erase_icloud", fallback: "Erase profiles from iCloud")
      /// Keep in menu bar
      public static let keepsInMenu = Strings.tr("Localizable", "views.preferences.keeps_in_menu", fallback: "Keep in menu bar")
      /// Launch on login
      public static let launchesOnLogin = Strings.tr("Localizable", "views.preferences.launches_on_login", fallback: "Launch on login")
      /// Lock in background
      public static let locksInBackground = Strings.tr("Localizable", "views.preferences.locks_in_background", fallback: "Lock in background")
      public enum EraseIcloud {
        /// To erase all profiles from the iCloud store securely, do so on all your synced devices. This will not affect local profiles.
        public static let footer = Strings.tr("Localizable", "views.preferences.erase_icloud.footer", fallback: "To erase all profiles from the iCloud store securely, do so on all your synced devices. This will not affect local profiles.")
      }
      public enum KeepsInMenu {
        /// Enable this to keep the app in the menu bar after closing it.
        public static let footer = Strings.tr("Localizable", "views.preferences.keeps_in_menu.footer", fallback: "Enable this to keep the app in the menu bar after closing it.")
      }
      public enum LaunchesOnLogin {
        /// Open the app in background after login.
        public static let footer = Strings.tr("Localizable", "views.preferences.launches_on_login.footer", fallback: "Open the app in background after login.")
      }
      public enum LocksInBackground {
        /// Lock the app with FaceID when sent to the background.
        public static let footer = Strings.tr("Localizable", "views.preferences.locks_in_background.footer", fallback: "Lock the app with FaceID when sent to the background.")
      }
    }
    public enum Profile {
      public enum Alerts {
        public enum Purchase {
          public enum Buttons {
            /// Save anyway
            public static let ok = Strings.tr("Localizable", "views.profile.alerts.purchase.buttons.ok", fallback: "Save anyway")
          }
        }
      }
      public enum ModuleList {
        public enum Section {
          /// Drag modules to rearrange them, as their order determines priority.
          public static let footer = Strings.tr("Localizable", "views.profile.module_list.section.footer", fallback: "Drag modules to rearrange them, as their order determines priority.")
        }
      }
      public enum Rows {
        /// Add module
        public static let addModule = Strings.tr("Localizable", "views.profile.rows.add_module", fallback: "Add module")
      }
      public enum Sections {
        public enum Name {
          /// Use this name to create your VPN automations from the Shortcuts app.
          public static let footer = Strings.tr("Localizable", "views.profile.sections.name.footer", fallback: "Use this name to create your VPN automations from the Shortcuts app.")
        }
      }
    }
    public enum Providers {
      /// Clear filters
      public static let clearFilters = Strings.tr("Localizable", "views.providers.clear_filters", fallback: "Clear filters")
      /// Last updated on %@
      public static func lastUpdated(_ p1: Any) -> String {
        return Strings.tr("Localizable", "views.providers.last_updated", String(describing: p1), fallback: "Last updated on %@")
      }
      /// None
      public static let noProvider = Strings.tr("Localizable", "views.providers.no_provider", fallback: "None")
      /// Only favorites
      public static let onlyFavorites = Strings.tr("Localizable", "views.providers.only_favorites", fallback: "Only favorites")
      /// Refresh infrastructure
      public static let refreshInfrastructure = Strings.tr("Localizable", "views.providers.refresh_infrastructure", fallback: "Refresh infrastructure")
      /// Select
      public static let selectEntity = Strings.tr("Localizable", "views.providers.select_entity", fallback: "Select")
      /// Select a provider
      public static let selectProvider = Strings.tr("Localizable", "views.providers.select_provider", fallback: "Select a provider")
      public enum LastUpdated {
        /// Loading...
        public static let loading = Strings.tr("Localizable", "views.providers.last_updated.loading", fallback: "Loading...")
      }
    }
    public enum Purchased {
      /// No purchases
      public static let noPurchases = Strings.tr("Localizable", "views.purchased.no_purchases", fallback: "No purchases")
      /// Purchased
      public static let title = Strings.tr("Localizable", "views.purchased.title", fallback: "Purchased")
      public enum Rows {
        /// Build number
        public static let buildNumber = Strings.tr("Localizable", "views.purchased.rows.build_number", fallback: "Build number")
        /// Download date
        public static let downloadDate = Strings.tr("Localizable", "views.purchased.rows.download_date", fallback: "Download date")
      }
      public enum Sections {
        public enum Download {
          /// First download
          public static let header = Strings.tr("Localizable", "views.purchased.sections.download.header", fallback: "First download")
        }
      }
    }
    public enum Ui {
      public enum ConnectionStatus {
        ///  (on-demand)
        public static let onDemandSuffix = Strings.tr("Localizable", "views.ui.connection_status.on_demand_suffix", fallback: " (on-demand)")
      }
      public enum PurchaseRequired {
        public enum Purchase {
          /// Purchase required
          public static let help = Strings.tr("Localizable", "views.ui.purchase_required.purchase.help", fallback: "Purchase required")
        }
        public enum Restricted {
          /// Feature is restricted
          public static let help = Strings.tr("Localizable", "views.ui.purchase_required.restricted.help", fallback: "Feature is restricted")
        }
      }
    }
    public enum Verification {
      /// Verifying...
      public static let message = Strings.tr("Localizable", "views.verification.message", fallback: "Verifying...")
    }
    public enum Version {
      /// %@ is a project maintained by %@.
      /// 
      /// Source code is publicly available on GitHub under the GPLv3, you can find links in the home page.
      public static func extra(_ p1: Any, _ p2: Any) -> String {
        return Strings.tr("Localizable", "views.version.extra", String(describing: p1), String(describing: p2), fallback: "%@ is a project maintained by %@.\n\nSource code is publicly available on GitHub under the GPLv3, you can find links in the home page.")
      }
    }
    public enum Vpn {
      /// No servers
      public static let noServers = Strings.tr("Localizable", "views.vpn.no_servers", fallback: "No servers")
      /// Preset
      public static let preset = Strings.tr("Localizable", "views.vpn.preset", fallback: "Preset")
      public enum Category {
        /// All categories
        public static let any = Strings.tr("Localizable", "views.vpn.category.any", fallback: "All categories")
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Strings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = Bundle.module.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
// swiftlint:enable all
