# Supported Destination Countries

## ✅ Confirmed Working with Wise API

### Top Remittance Corridors (by volume)

| Country | Currency | Symbol | Wise Support |
|---------|----------|--------|--------------|
| 🇮🇳 India | INR | ₹ | ✅ Already Implemented |
| 🇵🇭 Philippines | PHP | ₱ | ✅ Tested (9 providers) |
| 🇲🇽 Mexico | MXN | $ | ✅ Tested (11 providers) |
| 🇵🇰 Pakistan | PKR | ₨ | ✅ (To test) |
| 🇧🇩 Bangladesh | BDT | ৳ | ✅ (To test) |
| 🇳🇬 Nigeria | NGN | ₦ | ✅ (To test) |
| 🇻🇳 Vietnam | VND | ₫ | ✅ (To test) |
| 🇪🇬 Egypt | EGP | £ | ✅ (To test) |
| 🇮🇩 Indonesia | IDR | Rp | ✅ (To test) |
| 🇨🇴 Colombia | COP | $ | ✅ (To test) |

### Popular European Destinations

| Country | Currency | Symbol | Wise Support |
|---------|----------|--------|--------------|
| 🇬🇧 UK | GBP | £ | ✅ (Source only) |
| 🇪🇺 Eurozone | EUR | € | ✅ (Source & Target) |
| 🇵🇱 Poland | PLN | zł | ✅ (To test) |
| 🇷🇴 Romania | RON | lei | ✅ (To test) |

### Other Key Markets

| Country | Currency | Symbol | Wise Support |
|---------|----------|--------|--------------|
| 🇨🇳 China | CNY | ¥ | ✅ (To test) |
| 🇦🇺 Australia | AUD | $ | ✅ (To test) |
| 🇨🇦 Canada | CAD | $ | ✅ (To test) |
| 🇧🇷 Brazil | BRL | R$ | ✅ (To test) |
| 🇿🇦 South Africa | ZAR | R | ✅ (To test) |
| 🇯🇵 Japan | JPY | ¥ | ✅ (To test) |
| 🇰🇷 South Korea | KRW | ₩ | ✅ (To test) |
| 🇹🇭 Thailand | THB | ฿ | ✅ (To test) |
| 🇸🇬 Singapore | SGD | $ | ✅ (To test) |

## 🎯 Initial Implementation (Phase 1)
Start with top 5 remittance corridors:
1. India (INR) - Already done ✅
2. Philippines (PHP) - Most popular after India
3. Mexico (MXN) - Large market from USA
4. Pakistan (PKR) - High demand
5. Bangladesh (BDT) - Growing market

## 📱 UI Design
- Second picker below source currency
- "Sending to" label
- Flag emoji + currency code
- Same persistence logic (UserDefaults)

