All-in-One Remote Water Consumption Reading Platform

Goal
  Build a high-performance, multi-tenant, **Utility Management Platform** managing Customers, Subscriptions, Meters (Assets), and Devices (IoT). The platform will be capable of handling 1M+ concurrent requests and 10K+ user actively checking live data that transport over Socket.

Tech
  1. Infrastructure & DevOps
      1. Docker, Docker Compose, Dockerfile (Production-ready multi-stage builds)
      2. PostgreSQL
          1. TimescaleDB - timescale/timescaledb official docker image
          2. Ltree extension
      3. Redis for caching and queries
  2. Backend (Typescript)
      1. NestJS
      2. Prisma 6
      3. Kysely
      4. Socket.io (Redis Streams Adapter)
      5. Redis
          1. Redis Streams Adapter (for Socket.io)
          2. Bull MQ
      6. PassportJS
  3. Frontend (Typescript)
      1. Vue 3
      2. Nuxt 4
      3. Pinia
      4. Socket.io
      5. Shadcn
      6. Tailwind
      7. Leaflet

Structure
  1. Definitions
      1. Subscription Types
          1. Individual
          2. Organizational
      2. Meter Types
          1. Single Jet
          2. Multi Jet
          3. Woltman Paralel
          4. Woltman Vertical
          5. Volumetric (Rotary Piston)
          6. Ultrasonic
          7. Electromagnetic
          8. Compound
          9. Irrigation (Tangential/Paddle)
      3. Dial Types
          1. Semi-Dry Dial
          2. Dry Dial
          3. Super-Dry Dial
          4. Wet Dial
      4. Temperature Types
          1. T30 (Cold)
          2. T90 (Hot)
      5. Mounting Types
          1. Vertical
          2. Horizontal
          3. Both
      6. Connection Types
          1. Thread (Dişli / Rakorlu)
          2. Flange (Flanşlı)
      7. IP Ratings
          1. IP54
          2. IP65
          3. IP67
          4. IP68
          5. …
      8. Meter Statuses
          1. Active
          2. Passive
          3. Warehouse
          4. Maintenance
          5. Planned
          6. Deployed but not started
          7. Used
      9. Device Statuses
          1. Active
          2. Passive
          3. Warehouse
          4. Maintenance
          5. Planned
          6. Deployed but not started
          7. Used
      10. Communication Modules
          1. Integrated in meter
          2. Retrofit
          3. None
      11. Communication Technologies
          1. Sigfox (HTTP or API)
              1. Fields while adding meters
                  1. Key Name: ID, Key Type: Hexadecimal String, Key Length: 8, Validation Regex: ^[a-fA-F0-9]{8}$
                  2. Key Name: PAC, Key Type: Hexadecimal String, Key Length: 16, Validation Regex: ^[a-fA-F0-9]{16}$
          2. LoRaWAN (MQTT or HTTP or API)
              1. Fields while adding meters
                  1. Key Name: DevEUI, Key Type: Hexadecimal String, Key Length: 16, Validation Regex: ^[a-fA-F0-9]{16}$
                  2. Key Name: JoinEUI, Key Type: Hexadecimal String, Key Length: 16, Validation Regex: ^[a-fA-F0-9]{16}$
                  3. Key Name: AppKey, Key Type: Hexadecimal String, Key Length: 32, Validation Regex: ^[a-fA-F0-9]{32}$
          3. NB-IoT (MQTT or HTTP or API)
              1. Fields while adding meters
                  1. ...
                  2. …
          4. wM-Bus (MQTT or HTTP or API)
              1. Fields while adding meters
                  1. …
                  2. …
          5. Mioty (MQTT or HTTP or API)
              1. Fields while adding meters
                  1. …
                  2. …
          6. Wi-Fi (MQTT or HTTP or API)
              1. Fields while adding meters
                  1. …
                  2. …
          7. Bluetooth (MQTT or HTTP or API)
              1. Fields while adding meters
                  1. …
                  2. …
          8. NFC (MQTT or HTTP or API)
              1. Fields while adding meters
                  1. …
                  2. …
          9. OMS (MQTT or HTTP or API)
              1. Fields while adding meters
                  1. …
                  2. …
      12. Meter Brands
          1. Baylan
          2. Manas
          3. Itron
          4. Klepsan
          5. Cem
          6. Zenner
          7. Türkoğlu
          8. Bereket
          9. Teksan
      13. Device Brands
          1. Ima
          2. Itron
          3. Manas
          4. Inodya
          5. Zenner
          6. Baylan
          7. Cem
          8. Klepsan
      14. Shared Entities (Will not be shown on the navigation bar)
          1. Addresses
              1. Name
              2. Latitude
              3. Longitude
              4. City
              5. District
              6. Neighborhood
              7. Street
              8. Building no
              9. Floor
              10. Door no
              11. Postal code
              12. Address code (UAVT)
              13. Address Description
              14. Extra details in text
      15. Subscription Groups
          1. Normal Consumption
          2. High Consumption

  2. Modules/Views
      1. Dashboard
          1. Subscriptions
              1. Show on the map with the correct position (lat, lng) and indicators (symbols and colors)
                  1. Red: Alarm (tamper detection - Low Battery - Tilt - Reverse Flow)
                  2. Orange: High water usage
                  3. Green: No problem, Normal usage
                  4. Grey: No signal/Offline
          2. Alerts
              1. Count
              2. Latest Alarms
          3. Total Subscription Count
          4. Total Meter Count
          5. Total Device Count
          6. Total Water Usage
          7. Meters that are out of service / on maintenance /etc.
              1. Shows meters or remote devices that is not in use
      2. Live Readings
          1. Dashboard
              1. All Readings Table (Meter ID | Date & Time {DD.MM.YYYY HH:mm:ss} | Customer | Location (Lat, Lng) | Meter Brand | Type) (30 records per page)
      3. Subscriptions
          1. Dashboard
              1. All Subscriptions Table (Subscription ID | TC/Tax ID | Consumption | Address)
          2. Selected Subscription
              1. Subscription Info Card
              2. Related Customer (from 2.4: Modules/Views -> Customers)
              3. Related Meter (from 2.5: Modules/Views -> Meters)
              4. Related Device (from 2.6: Modules/Views -> Devices)
              5. Address (from 1.14.1: Definitions -> Shared Entities -> Addresses)
              6. Consumption History Chart
                  1. Total
                  2. By Meter
                  3. By Device
          3. Create/Update Page/Dialog/Form
              1. Tenant
              2. ID
              3. Address (to 1.14.1: Definitions -> Shared Entities -> Addresses)
              4. Customer (from 3 -> Customer)
              5. Meter (From 4 -> Meters)
              6. Device (From 5 -> Devices)
              7. Subscription Type (From 1.1: Definitions -> Subscription Types)
              8. Subscription Group (From 1.15: Definitions -> Subscription Groups)
              9. Customer
                  1. Select From Existing (from 2.4: Modules/Views -> Customers)
                  2. Create New
                      1. Fields
                          1. If 2.3.3.6 (Modules/Views -> Subscriptions -> Create/Update Page/Dialog/Form -> Subscription Type) is 1.1.1 (Definitions -> Subscription Types -> Individual)
                              1. Name
                              2. Surname
                              3. TC ID No
                              4. Phone number
                              5. Email
                              6. If Another Contact
                                  1. Contact name/s
                                  2. Contact surname
                                  3. Contact TC ID No
                                  4. Contact phone number
                                  5. Contact email
                                  6. Other details if needed
                                  7. Address (to 1.14.1 -> Definitions -> Shared Entities -> Addresses)
                          2. If 2.3.3.6 (Modules/Views -> Subscriptions -> Create/Update Page/Dialog/Form -> Subscription Type) is 1.1.2 (Definitions -> Subscription Types -> Organizational)
                              1. Organization name (full name)
                              2. Tax ID
                              3. Tax Office
                              4. Contact name
                              5. Contact surname
                              6. Contact phone number
                              7. Contact email
                              8. Address (to 1.14.1 -> Definitions -> Shared Entities -> Addresses)
      4. Customers
          1. Dashboard
              1. All customer table
          2. Selected Customer Detail
              1. Customer Info Card
              2. Addresses List
              3. Related Subscriptions Expandable Table
                  1. Address
                  2. Related Meter
                  3. Related Device
              4. Consumption History Chart
          3. Create/Update Page/Dialog/Form
              1. Tenant
              2. Name/s
              3. Surname
              4. TC ID No
              5. Phone Number
              6. Email
      5. Meters (Assets)
          1. Dashboard
              1. All meters table (Filterable by Tenant, Status, Brand)
          2. Selected meter detail
              1. Technical Info Card (Brand, Model, Serial)
              2. Address (from 2.3.2.5: Modules/Views -> Subscriptions -> Address)
              3. Status & Connectivity Info (Signal Strength, Battery)
              4. Valve Status (Open/Close - If applicable)
              5. Reading History Chart
          3. Create/Update Page/Dialog/Form
              1. Tenant
              2. Related Subscription (from 2.3: Modules/Views -> Subscriptions) (optional - may be added later)
              3. Meter Profile (from 2.7.1: Definitions -> Profiles -> Meter Profiles) (Filtered by Tenant -> Allowed Profiles)
              4. Serial No / ID
              5. Initial Index
              6. Installation Date (DD.MM.YYYY HH:mm:ss -> 08.12.2025 07:18:55)(24 hours and no am/pm)
              7. Meter Status (from 1.8: Definitions -> Meter Statuses)
              8. Tenant (from 2.8.1: IAM -> Modules/Views -> IAM -> Tenants)
              9. Communication Module (Can overwrite the profile)
              10. Device Configurations
                  1. None
                  2. Select From Inventory
                  3. Create New
      6. Devices
          1. Dashboard
              1. All devices table
          2. Selected device detail
              1. Device Info Card
              2. Address (from 2.3.2.5: Modules/Views -> Subscriptions -> Address)
              3. Device Statuses
              4. Reading History Table
          3. Create/Update Page/Dialog/Form
              1. Tenant (from 2.8.1: IAM -> Modules/Views -> IAM -> Tenants)
              2. Related Meter (from 2.5: Modules/Views -> Meters) (Optional - may be added later)
              3. Serial No / ID
              4. Device Status (from 1.9: -> Definitions -> Device Statuses)
              5. Device Profile (from 2.7.2: Definitions -> Profiles -> Device Profiles)
              6. Dynamic fields (from 2.7.2.6: Device Profiles -> Communication Technologies)
      7. Profiles
          1. Meter Profiles
              1. Brand (from 1.12: Definitions -> Meter Brands)
              2. Model Code (Brand + Model Code must be unique)
              3. Meter Type (from 1.2: Definitions -> Meter Types)
              4. Dial Type (from 1.3: Definitions -> Dial Types)
              5. Temperature Type (from 1.4: Definitions -> Temperature Types)
              6. Mounting Type (from 1.5: Definitions -> Mounting Types)
              7. Connection Type (from 1.6: Definitions -> Connection Types)
              8. IP Rating (from 1.7: Definitions -> IP Ratings)
              9. Diameter
              10. Length
              11. Width
              12. Height
              13. Q1 (Qmin)
              14. Q2 (Qt)
              15. Q3 (Qn)
              16. Q4 (Qmax)
              17. R Value (Can be automatically calculated from Q3/Q1 or can be written manually)
              18. Pressure Loss
              19. Communication Module (from 1.0: Definitions -> Communication Modules)
              20. Compatible Device Profiles (From 2.7.2: Modules/Views -> Profiles -> Device Profiles)
          2. Device Profiles
              1. Device Brand (from 13)
              2. Model Code (Device Brand + Model Code must be unique)
              3. Messaging Scenarios
              4. Battery Life (If communication module is not none)
              5. Compatible Meter Profiles (From 2.7.1: Modules/Views -> Profiles -> Meter Profiles)
              6. Communication Technologies (from 1.11: Definitions -> Communication Technologies)
                  1. Sigfox
                      1. Fields (Must be dynamically added while adding meters)(from 1.11.1.1: Definitions -> Communication technologies -> Sigfox -> Fields while adding meters)
                      2. Message Scenarios (from 2.7.2.3: Modules/Views -> Profiles -> Device Profiles -> Messaging Scenarios) (can be more than one)
                          1. Decoder function (JS expressions)
                  2. LoRaWAN
                      1. Fields (Must be dynamically added while adding meters)(from 1.11.2.1: Definitions -> Communication technologies -> LoRaWAN -> Fields while adding meters)
                      2. Message Scenarios (from 2.7.2.3: Modules/Views -> Profiles -> Device Profiles -> Messaging Scenarios) (can be more than one)
                          1. Decoder function (JS expressions)
                  3. NB-IoT
                      1. Fields (Must be dynamically added while adding meters)(from 1.11.3.1: Definitions -> Communication technologies -> LoRaWAN -> Fields while adding meters)
                      2. Message Scenarios (from 2.7.2.3: Modules/Views -> Profiles -> Device Profiles -> Messaging Scenarios) (can be more than one)
                          1. Decoder function (JS expressions)
                  4. …
                  5. …
                  6. …
                  7. …
                  8. …
                  9. …
      8. IAM
          1. Tenants
              1. Dashboard
                  1. Treetable (Tenant name)
              2. Selected tenant details
                  1. Company Info Card (Name, Tax ID, Address)
                  2. Subscription Status (Active/Passive, Plan Type)
                  3. Summary Stats: (Total Users, Total Meters, Active Alarms)
                  4. Users list (List of users assigned to this tenant)
                  5. Allowed Profiles List (Which meter models they can use)
              3. Create/Update Page/Dialog/Form
                  1. Parent Tenant (from 2.8.1: IAM -> Tenants)
                  2. Name
                  3. Contact name/s
                  4. Contact surname
                  5. Contact phone number
                  6. Contact email
                  7. Tax ID
                  8. Tax office
                  9. Tenant address (from 1.14.1: Definitions -> Shared Entities -> Addresses)
                  10. Users list (from 2.8.2)
                      1. Select from existing
                          1. Modules & Permissions Matrix
                  11. Existed users list (read-only)
                  12. Allowed meter profiles (from 5.1: Profiles -> Meter Profiles) (Multi-select)
          2. Users
              1. Dashboard
                  1. Table (User name/s + User Surname | Tenant Name)
              2. Selected user details
                  1. User Info Card (Name, Email, Phone)
                  2. Activity Log (Last login, Last actions)
                  3. Assigned Tenants Table (Tenant Name | Role)
              3. Create/Update Page/Dialog/Form
                  1. Name/s
                  2. Surname
                  3. Phone number
                  4. Email
                  5. TC ID No
                  6. Tenants list (from 2.8.1)
                      1. Select from existing
                          1. Modules & Permissions Matrix
                  7. Existed tenants list (read-only)

Relations & Logic
  1. Tenants
      1. A tenant must have a parent tenant (if it is not the root tenant)
      2. “Una IoT” will be the one and only root tenant
      3. A tenant can have multiple child tenants
      4. A tenant can have multiple customers
      5. A tenant can have multiple users
      6. Parent tenants can be able to manage child tenants
      7. Child tenants must not be able to see its parent tenant or any same level sibling tenants.
      8. Tenants can have multiple allowed meter profiles
  2. Users
      1. iot@una.net.tr will be the default user with all permissions on all modules under “Una IoT” tenant
      2. A user must be related with tenants
      3. A user can be related with different tenants
      4. A user may or may not have permissions for suitable tenants
      5. An authorized user of a tenant can be able to manage all of its child tenants
      6. A user must not be able to see its parent tenant or any of same level sibling tenants
      7. A user can only access the views if the permissions are given, and cannot access the views if the permissions are not given
  3. Customers
      1. A customer must be related with at least and only 1 tenant
      2. A customer can have n subscriptions
  4. Subscriptions
      1. A subscription can be related with at least and only 1 customer (thus can only be related with only one tenant)
      2. A subscription can have 1 linked meter at a time
      3. A subscription can be related with n meters (a customer can change meters, e.g, old meters)
  5. Meter Profiles
      1. A meter profile can be consumed by multiple meters
      2. A meter profile view can be allowed for multiple tenants
      3. A meter profile can have multiple compatible device profiles
  6. Meters (Assets)
      1. A meter must be related with at least and only 1 tenant
      2. A meter may or may not be related with a subscription
      3. A meter must be related with at least and only 1 meter profiles
      4. A meter may or may not be related with device (If related, only 1)
  7. Device Profiles
      1. A device profile can have multiple devices
      2. A device profile can have multiple compatible meter profiles
  8. Devices
      1. A device must be related with at least and only 1 tenant
      2. A device may or may not be related with a meter (If related, only 1)
      3. A device must be related with at least 1 device profile
Seed
  1. Tenants
      1. Root (Una IoT)
          1. ASKİ (Ankara Su İdaresi)
          2. HATSU (Hatay Su İdaresi)
  2. Users
      1. Super Admin
          1. Name: Una IoT
          2. Surname: Super Admin
          3. Email: iot@una.net.tr
          4. Password: Asdf1234.
          5. Phone: +909998887766
          6. TC ID: 12345678901
          7. Permissions:
              1. Create+Read+Update+Delete->All Modules
      2. Aski Yetkili
          1. First Name: ASKİ
          2. Last Name: Yetkili
          3. Email: aski.yetkili@example.com
          4. password: Asdf1234.
          5. Phone: +908887776655
          6. TC ID: 12345678902
          7. Permissions:
              1. Create+Read+Update+Delete->All Modules
      3. Hatsu Yetkili
          1. First Name: HATSU
          2. Last Name: Yetkili
          3. Email: hatsu.yetkili@example.com
          4. password: Asdf1234.
          5. Phone: +907776665544
          6. TC ID: 12345678903
          7. Permissions:
              1. Create+Read+Update+Delete->All Modules
  3. Brands
      1. Meter Brands
          1. Baylan
          2. Manas
          3. Itron
          4. Klepsan
          5. Cem
          6. Zenner
          7. Türkoğlu
          8. Bereket
          9. Teksan
      2. Device Brands
          1. Ima
          2. Itron
          3. Manas
          4. Inodya
          5. Zenner
          6. Baylan
          7. Cem
          8. Klepsan
  4. Profiles
      1. (Total 10) Quantity | Meter Profiles | Compatible Device Profiles | Viewable by Tenants (Root is default and must)
          1. 2 | Manas | Manas + Itron + Ima + Inodya | HATSU
          2. 2 | Itron | Manas + Itron + Ima + Inodya | ASKİ + HATSU
          3. 2 | Baylan | Baylan + IMA | ASKİ + HATSU
          4. 2 | Zenner | Ima | HATSU
          5. 1 | Cem | Cem + Ima | HATSU
          6. 1 | Klepsan | Klepsan + Ima | HATSU
      2. (Total 7) Quantity | Device Profiles | Compatible Meter Profiles | Viewable by Tenants (Root is default and must)
          1. 1 | Manas | Manas + Itron | HATSU + ASKİ
          2. 1 | Itron | Itron | HATSU + ASKİ
          3. 1 | Baylan | Baylan | HATSU + ASKİ
          4. 1 | Cem | Cem | HATSU
          5. 1 | Klepsan | Klepsan | HATSU
          6. 1 | Ima | Baylan + Manas + Itron + Klepsan + Cem + Zenner + Türkoğlu + Bereket + Teksan | HATSU + ASKİ
          7. 1 | Inodya | Manas + Itron | HATSU + ASKİ
  5. Customers
      1. ASKİ
          1. 100
      2. HATSU
          1. 64
  6. Subscriptions
      1. ASKİ
          1. 128
      2. HATSU
          1. 50
  7. Meters
      1. ASKİ
          1. 100
      2. HATSU
          1. 50
  8. Devices
      1. ASKİ
          1. 100
      2. HATSU
          1. 50
  9. Live Readings
      1. All devices
      2. 45 days
      3. 24 Messages per day