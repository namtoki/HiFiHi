# Seed data for HiFi Audio Platform

puts "Seeding categories..."
categories = {
  speaker: Category.find_or_create_by!(name: "speaker") { |c| c.display_name = "スピーカー"; c.sort_order = 1 },
  amplifier: Category.find_or_create_by!(name: "amplifier") { |c| c.display_name = "アンプ"; c.sort_order = 2 },
  dac: Category.find_or_create_by!(name: "dac") { |c| c.display_name = "DAC"; c.sort_order = 3 },
  headphone: Category.find_or_create_by!(name: "headphone") { |c| c.display_name = "ヘッドホン"; c.sort_order = 4 },
  turntable: Category.find_or_create_by!(name: "turntable") { |c| c.display_name = "ターンテーブル"; c.sort_order = 5 },
  cable: Category.find_or_create_by!(name: "cable") { |c| c.display_name = "ケーブル"; c.sort_order = 6 }
}

puts "Seeding brands..."
brands = {
  dali: Brand.find_or_create_by!(slug: "dali") { |b| b.name = "DALI"; b.country = "Denmark"; b.description = "デンマークの高級スピーカーメーカー" },
  kef: Brand.find_or_create_by!(slug: "kef") { |b| b.name = "KEF"; b.country = "United Kingdom"; b.description = "イギリスの老舗スピーカーブランド" },
  marantz: Brand.find_or_create_by!(slug: "marantz") { |b| b.name = "Marantz"; b.country = "Japan"; b.description = "日本のオーディオ機器メーカー" },
  denon: Brand.find_or_create_by!(slug: "denon") { |b| b.name = "Denon"; b.country = "Japan"; b.description = "日本の大手オーディオブランド" },
  ifi: Brand.find_or_create_by!(slug: "ifi-audio") { |b| b.name = "iFi Audio"; b.country = "United Kingdom"; b.description = "イギリスのDAC/ヘッドホンアンプメーカー" },
  topping: Brand.find_or_create_by!(slug: "topping") { |b| b.name = "TOPPING"; b.country = "China"; b.description = "中国のハイコスパDAC/アンプブランド" },
  sennheiser: Brand.find_or_create_by!(slug: "sennheiser") { |b| b.name = "Sennheiser"; b.country = "Germany"; b.description = "ドイツの老舗ヘッドホンメーカー" },
  audio_technica: Brand.find_or_create_by!(slug: "audio-technica") { |b| b.name = "Audio-Technica"; b.country = "Japan"; b.description = "日本のオーディオ機器メーカー" }
}

puts "Seeding equipment..."

# Speakers
oberon5 = Equipment.find_or_create_by!(slug: "dali-oberon-5") do |e|
  e.category = categories[:speaker]
  e.brand = brands[:dali]
  e.model = "OBERON 5"
  e.release_year = 2018
  e.msrp_jpy = 176000
  e.status = "active"
  e.specs = {
    type: "floorstanding",
    impedanceOhm: 6,
    sensitivityDb: 88,
    frequencyHz: [39, 26000],
    powerWMin: 30,
    powerWMax: 150,
    drivers: { tweeter: "29mm soft dome", woofer: "2x 5.25 inch wood fiber" },
    dimensions: { heightMm: 830, widthMm: 162, depthMm: 283 },
    weightKg: 11.8
  }
  e.description = "DALI OBERONシリーズのフロアスタンディングスピーカー。SMC磁気システムとWood Fiber Coneドライバーを搭載。"
  e.features = ["SMC磁気システム", "Wood Fiber Cone", "リアバスレフ"]
end

ls50meta = Equipment.find_or_create_by!(slug: "kef-ls50-meta") do |e|
  e.category = categories[:speaker]
  e.brand = brands[:kef]
  e.model = "LS50 Meta"
  e.release_year = 2020
  e.msrp_jpy = 220000
  e.status = "active"
  e.specs = {
    type: "bookshelf",
    impedanceOhm: 8,
    sensitivityDb: 85,
    frequencyHz: [79, 28000],
    powerWMin: 40,
    powerWMax: 100,
    drivers: { tweeter: "Uni-Q with MAT" },
    dimensions: { heightMm: 302, widthMm: 200, depthMm: 278 },
    weightKg: 7.7
  }
  e.description = "KEFの人気ブックシェルフスピーカー。Metamaterial Absorption Technology搭載。"
  e.features = ["Uni-Q ドライバー", "MAT技術", "バスレフ"]
end

# Amplifiers
pm7000n = Equipment.find_or_create_by!(slug: "marantz-pm7000n") do |e|
  e.category = categories[:amplifier]
  e.brand = brands[:marantz]
  e.model = "PM7000N"
  e.release_year = 2019
  e.msrp_jpy = 132000
  e.status = "active"
  e.specs = {
    type: "integrated",
    outputW8ohm: 60,
    outputW4ohm: 80,
    thdPercent: 0.02,
    inputTypes: ["RCA", "Phono MM", "Optical", "Coaxial"],
    networkStreaming: true,
    heos: true
  }
  e.description = "Marantzのネットワーク対応プリメインアンプ。HEOS搭載でストリーミング対応。"
  e.features = ["HEOS Built-in", "Hi-Res対応", "Phono入力"]
end

pma600ne = Equipment.find_or_create_by!(slug: "denon-pma-600ne") do |e|
  e.category = categories[:amplifier]
  e.brand = brands[:denon]
  e.model = "PMA-600NE"
  e.release_year = 2018
  e.msrp_jpy = 55000
  e.status = "active"
  e.specs = {
    type: "integrated",
    outputW8ohm: 45,
    outputW4ohm: 70,
    thdPercent: 0.07,
    inputTypes: ["RCA", "Phono MM", "Optical", "Coaxial"],
    bluetoothAptx: true
  }
  e.description = "Denonのエントリークラスプリメインアンプ。Bluetooth aptX対応。"
  e.features = ["Advanced High Current", "Bluetooth aptX", "Phono入力"]
end

# DACs
zendac = Equipment.find_or_create_by!(slug: "ifi-audio-zen-dac-v2") do |e|
  e.category = categories[:dac]
  e.brand = brands[:ifi]
  e.model = "ZEN DAC V2"
  e.release_year = 2021
  e.msrp_jpy = 23980
  e.status = "active"
  e.specs = {
    bitDepth: 32,
    sampleRateKhz: 384,
    dsdSupport: true,
    dsdNative: "DSD256",
    inputs: ["USB"],
    outputs: ["RCA", "4.4mm Balanced", "6.3mm"]
  }
  e.description = "iFi Audioのデスクトップ向けUSB DAC/ヘッドホンアンプ。MQAフルデコード対応。"
  e.features = ["MQAフルデコード", "バランス出力", "PowerMatch"]
end

d90se = Equipment.find_or_create_by!(slug: "topping-d90se") do |e|
  e.category = categories[:dac]
  e.brand = brands[:topping]
  e.model = "D90SE"
  e.release_year = 2021
  e.msrp_jpy = 99800
  e.status = "active"
  e.specs = {
    bitDepth: 32,
    sampleRateKhz: 768,
    dsdSupport: true,
    dsdNative: "DSD512",
    inputs: ["USB", "Optical", "Coaxial", "AES/EBU", "I2S"],
    outputs: ["RCA", "XLR Balanced"],
    dacChip: "ESS ES9038PRO"
  }
  e.description = "TOPPINGのフラッグシップDAC。ES9038PRO搭載。"
  e.features = ["ES9038PRO", "フルバランス設計", "リモコン付属"]
end

# Headphones
hd660s2 = Equipment.find_or_create_by!(slug: "sennheiser-hd-660s2") do |e|
  e.category = categories[:headphone]
  e.brand = brands[:sennheiser]
  e.model = "HD 660S2"
  e.release_year = 2022
  e.msrp_jpy = 74800
  e.status = "active"
  e.specs = {
    type: "open-back",
    impedanceOhm: 300,
    sensitivityDb: 104,
    frequencyHz: [8, 41500],
    driverSize: 42,
    weightG: 260,
    cableLength: 1.8
  }
  e.description = "Sennheiserの開放型ヘッドホン。HD 660Sの後継機。"
  e.features = ["開放型", "新設計ドライバー", "着脱式ケーブル"]
end

athr70x = Equipment.find_or_create_by!(slug: "audio-technica-ath-r70x") do |e|
  e.category = categories[:headphone]
  e.brand = brands[:audio_technica]
  e.model = "ATH-R70x"
  e.release_year = 2015
  e.msrp_jpy = 44000
  e.status = "active"
  e.specs = {
    type: "open-back",
    impedanceOhm: 470,
    sensitivityDb: 99,
    frequencyHz: [5, 40000],
    driverSize: 45,
    weightG: 210,
    cableLength: 3.0
  }
  e.description = "Audio-Technicaのプロフェッショナル向け開放型ヘッドホン。"
  e.features = ["開放型", "軽量設計", "着脱式ケーブル"]
end

puts "Seeding compatibility data..."

Compatibility.find_or_create_by!(equipment_a: pm7000n, equipment_b: oberon5) do |c|
  c.compatibility_score = 5
  c.compatibility_details = {
    powerMatch: "excellent",
    impedanceMatch: "excellent",
    notes: "60W/8ohmの出力はOBERON 5の推奨入力30-150Wに十分対応。6ohmインピーダンスも問題なし。"
  }
  c.source = "calculated"
end

Compatibility.find_or_create_by!(equipment_a: pma600ne, equipment_b: ls50meta) do |c|
  c.compatibility_score = 4
  c.compatibility_details = {
    powerMatch: "good",
    impedanceMatch: "excellent",
    notes: "45W/8ohmはLS50 Metaの推奨40-100Wの下限だが、十分駆動可能。高音質を求めるならより高出力アンプ推奨。"
  }
  c.source = "calculated"
end

Compatibility.find_or_create_by!(equipment_a: zendac, equipment_b: pm7000n) do |c|
  c.compatibility_score = 5
  c.compatibility_details = {
    connectionMatch: "excellent",
    notes: "RCA接続で問題なく接続可能。DAC側の出力レベルもアンプ入力に最適。"
  }
  c.source = "calculated"
end

Compatibility.find_or_create_by!(equipment_a: zendac, equipment_b: hd660s2) do |c|
  c.compatibility_score = 5
  c.compatibility_details = {
    powerMatch: "excellent",
    impedanceMatch: "good",
    notes: "ZEN DACのヘッドホン出力は300ohmのHD 660S2を十分に駆動可能。バランス接続推奨。"
  }
  c.source = "calculated"
end

puts "Seed completed!"
puts "  Categories: #{Category.count}"
puts "  Brands: #{Brand.count}"
puts "  Equipment: #{Equipment.count}"
puts "  Compatibilities: #{Compatibility.count}"
