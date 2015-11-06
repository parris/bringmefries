import CoreBluetooth

struct LocationServiceConstants {
    // These UUIDs were randomly generated via uuidgen (from a bash terminal)
    static let serviceUUID = NSUUID(UUIDString: "178E4BFA-CECA-4141-9407-E6F104289051")!
    static let characteristicUUID = NSUUID(UUIDString: "10EA6D59-8A00-41A3-A206-137542FE9750")!
}