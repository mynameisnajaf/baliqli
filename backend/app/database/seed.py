"""Seed Azerbaijan fish species and sample content."""
import json

from sqlalchemy.orm import Session

from app.models.content import Recipe, Tutorial
from app.models.fish import FishSpecies
from app.models.gamification import Achievement
from app.models.marketplace import MarketplaceProduct
from app.models.spot import FishingSpot

FISH_SPECIES = [
    # freshwater
    dict(name_en="Common carp", name_az="Sazan", scientific_name="Cyprinus carpio", category="freshwater",
         habitat="Kür, Araz, göllər", description_az="Azərbaycanın ən məşhur şirin su balığı. Böyük ölçülərə çatır, yeməyə çox uyğundur.", rarity="common", has_recipes=True, has_tutorials=True),
    dict(name_en="Prussian carp", name_az="Gümüşü karas", scientific_name="Carassius gibelio", category="freshwater",
         habitat="Göllər, kanallar", description_az="Kiçik və orta ölçülü, dözümlü şirin su balığı.", rarity="common", has_recipes=True),
    dict(name_en="Crucian carp", name_az="Qızılı karas", scientific_name="Carassius carassius", category="freshwater",
         habitat="Batıq göllər", description_az="Sakit sularda yaşayan klassik karas.", rarity="common"),
    dict(name_en="Tench", name_az="Lin", scientific_name="Tinca tinca", category="freshwater",
         habitat="Göllər, sakit çaylar", description_az="Yaşıl-qəhvəyi rəngli, dibdə qidalanan balıq.", rarity="uncommon", has_recipes=True),
    dict(name_en="Wels catfish", name_az="Naxa", scientific_name="Silurus glanis", category="freshwater",
         habitat="Kür, Araz, böyük göllər", description_az="Azərbaycanın ən böyük şirin su yırtıcısı. Gecə ovlanır.", rarity="uncommon", has_recipes=True, has_tutorials=True),
    dict(name_en="Northern pike", name_az="Çökə", scientific_name="Esox lucius", category="freshwater",
         habitat="Göllər, bataqlıqlar", description_az="Uzun bədənli, dişli yırtıcı. Spinner və canlı yemlə tutulur.", rarity="uncommon", has_tutorials=True),
    dict(name_en="Zander", name_az="Durnabalığı", scientific_name="Sander lucioperca", category="freshwater",
         habitat="Kür, Xəzər sahili", description_az="Qiymətli yırtıcı, əti dadlıdır.", rarity="uncommon", has_recipes=True),
    dict(name_en="European perch", name_az="Xanımbaliğı", scientific_name="Perca fluviatilis", category="freshwater",
         habitat="Göllər, çaylar", description_az="Zolaqlı, aktiv yırtıcı. Yeni başlayanlar üçün ideal.", rarity="common", has_tutorials=True),
    dict(name_en="Bream", name_az="Çapak", scientific_name="Abramis brama", category="freshwater",
         habitat="Kür, göllər", description_az="Yastı bədənli, dibdən qidalanan balıq.", rarity="common", has_recipes=True),
    dict(name_en="Roach", name_az="Çökəcik", scientific_name="Rutilus rutilus", category="freshwater",
         habitat="Çaylar, göllər", description_az="Kiçik sürü balığı, yüngül olta ilə tutulur.", rarity="common"),
    dict(name_en="Asp", name_az="Qılınc balığı", scientific_name="Aspius aspius", category="freshwater",
         habitat="Kür, Araz", description_az="Sürətli yırtıcı, səthə yaxın ovlanır.", rarity="uncommon"),
    dict(name_en="Chub", name_az="Göy balıq", scientific_name="Squalius cephalus", category="river",
         habitat="Dağ çayları", description_az="Sürətli axınlarda yaşayan güclü balıq.", rarity="common"),
    dict(name_en="Barbel", name_az="Bıyıqlı balıq", scientific_name="Barbus cyri", category="river",
         habitat="Kür hövzəsi", description_az="Dibdə qidalanan, bıyıqlı çay balığı.", rarity="uncommon"),
    dict(name_en="Kura nase", name_az="Şirbit", scientific_name="Capoeta capoeta", category="river",
         habitat="Kür, Araz", description_az="Azərbaycana xas çay balığı.", rarity="common"),
    dict(name_en="Kura bleak", name_az="Külə", scientific_name="Alburnus filippii", category="river",
         habitat="Kür hövzəsi", description_az="Kiçik gümüşü sürü balığı.", rarity="common"),
    dict(name_en="Spined loach", name_az="Çay ilanbalığı", scientific_name="Cobitis taenia", category="river",
         habitat="Qumlu diblər", description_az="Kiçik dib balığı.", rarity="uncommon"),
    # Caspian / sea
    dict(name_en="Caspian kutum", name_az="Kütüm", scientific_name="Rutilus frisii kutum", category="sea",
         habitat="Xəzər dənizi, çay mənsəbləri", description_az="Xəzərin ən qiymətli balıqlarından. Yaz axını məşhurdur.", rarity="uncommon", has_recipes=True, has_tutorials=True),
    dict(name_en="Caspian shad", name_az="Xəşəm", scientific_name="Alosa caspia", category="sea",
         habitat="Xəzər dənizi", description_az="Yayda sahilə yaxın tutulan dadlı balıq.", rarity="common", has_recipes=True),
    dict(name_en="Flathead grey mullet", name_az="Kefal", scientific_name="Mugil cephalus", category="sea",
         habitat="Xəzər sahili", description_az="Sahil zonasında aktiv ovlanan balıq.", rarity="common", has_recipes=True),
    dict(name_en="Golden grey mullet", name_az="Qızılı kefal", scientific_name="Chelon auratus", category="sea",
         habitat="Xəzər sahili", description_az="Kefal ailəsindən gümüşü-qızılı balıq.", rarity="common"),
    dict(name_en="Caspian salmon", name_az="Qızılbalıq", scientific_name="Salmo trutta caspius", category="rare",
         habitat="Xəzər, dağ çayları", description_az="Nadir və qiymətli Xəzər qızılbalığı.", rarity="legendary", has_tutorials=True),
    dict(name_en="Beluga", name_az="Beluga nərə", scientific_name="Huso huso", category="rare",
         habitat="Xəzər dənizi", description_az="Dünyanın ən böyük nərə balığı. Qorunan növ.", rarity="legendary"),
    dict(name_en="Russian sturgeon", name_az="Rus nərəsi", scientific_name="Acipenser gueldenstaedtii", category="rare",
         habitat="Xəzər dənizi", description_az="Klassik nərə növü, qorunan.", rarity="legendary"),
    dict(name_en="Stellate sturgeon", name_az="Uzunburun nərə", scientific_name="Acipenser stellatus", category="rare",
         habitat="Xəzər dənizi", description_az="Uzun burunlu nərə. Qorunan növ.", rarity="rare"),
    dict(name_en="Persian sturgeon", name_az="İran nərəsi", scientific_name="Acipenser persicus", category="rare",
         habitat="Xəzər cənubu", description_az="Cənubi Xəzərə xas nərə.", rarity="legendary"),
    dict(name_en="Caspian trout", name_az="Xəzər alabalığı", scientific_name="Salmo caspius", category="rare",
         habitat="Dağ çayları, Xəzər", description_az="Soyuq sularda yaşayan alabalıq.", rarity="rare"),
    dict(name_en="Caspian roach", name_az="Xəzər küləsi", scientific_name="Rutilus caspicus", category="sea",
         habitat="Xəzər sahili", description_az="Sahil zonasında sürü halında yaşayır.", rarity="common"),
    dict(name_en="Caspian kilka", name_az="Kilkə", scientific_name="Clupeonella caspia", category="sea",
         habitat="Xəzər dənizi", description_az="Kiçik sürü balığı, sənaye əhəmiyyətli.", rarity="common", has_recipes=True),
    dict(name_en="Gobies", name_az="Bıyığlı xul", scientific_name="Neogobius melanostomus", category="sea",
         habitat="Xəzər sahili", description_az="Dibdə yaşayan kiçik balıq.", rarity="common"),
    dict(name_en="Caspian seal prey fish", name_az="Xəzər siyənəyi", scientific_name="Alosa braschnikowi", category="sea",
         habitat="Xəzər dənizi", description_az="Böyük siyənək növü.", rarity="uncommon"),
    # lake
    dict(name_en="Rainbow trout", name_az="Göyqurşağı alabalığı", scientific_name="Oncorhynchus mykiss", category="lake",
         habitat="Dağ gölləri, ferma", description_az="Soyuq göllərdə və fermələrdə yetişdirilir.", rarity="uncommon", has_recipes=True),
    dict(name_en="Brown trout", name_az="Çay alabalığı", scientific_name="Salmo trutta fario", category="river",
         habitat="Dağ çayları", description_az="Təmiz dağ sularında yaşayan alabalıq.", rarity="rare"),
    dict(name_en="Pike-perch lake", name_az="Göl durnabalığı", scientific_name="Sander volgensis", category="lake",
         habitat="Böyük göllər", description_az="Göl ekosistemlərində yırtıcı.", rarity="uncommon"),
    dict(name_en="Rudd", name_az="Qızılgöz", scientific_name="Scardinius erythrophthalmus", category="lake",
         habitat="Göllər, sakit su", description_az="Qırmızı üzgəcli gözəl balıq.", rarity="common"),
    dict(name_en="Bleak", name_az="Üzgəc", scientific_name="Alburnus alburnus", category="lake",
         habitat="Göllər, çaylar", description_az="Səthdə yaşayan kiçik gümüşü balıq.", rarity="common"),
    dict(name_en="Silver bream", name_az="Gümüşü çapak", scientific_name="Blicca bjoerkna", category="lake",
         habitat="Göllər", description_az="Çapak qohumu, daha kiçik.", rarity="common"),
    dict(name_en="Grass carp", name_az="Ağ amur", scientific_name="Ctenopharyngodon idella", category="freshwater",
         habitat="Göllər, kanallar", description_az="Bitki yeyən iri balıq.", rarity="uncommon", has_recipes=True),
    dict(name_en="Silver carp", name_az="Gümüşü amur", scientific_name="Hypophthalmichthys molitrix", category="freshwater",
         habitat="Göllər", description_az="Planktonla qidalanan sürü balığı.", rarity="common"),
    dict(name_en="Bighead carp", name_az="Böyükbaş amur", scientific_name="Hypophthalmichthys nobilis", category="freshwater",
         habitat="Göllər", description_az="İri plankton yeyən.", rarity="uncommon"),
    dict(name_en="European eel", name_az="İlanbalığı", scientific_name="Anguilla anguilla", category="rare",
         habitat="Çaylar, Xəzər bağlantıları", description_az="Nadir miqrant növ.", rarity="rare"),
    dict(name_en="Caspian white fish", name_az="Ağ balıq", scientific_name="Stenodus leucichthys", category="rare",
         habitat="Xəzər, Kür", description_az="Qiymətli və nadir ağ balıq.", rarity="legendary"),
    dict(name_en="Vimba", name_az="Çökə balığı", scientific_name="Vimba vimba", category="river",
         habitat="Kür hövzəsi", description_az="Yazda çaylara miqrasiya edir.", rarity="uncommon"),
    dict(name_en="Sabre carp", name_az="Qılınc", scientific_name="Pelecus cultratus", category="freshwater",
         habitat="Kür, göllər", description_az="Yastı, uzun bədənli balıq.", rarity="uncommon"),
    dict(name_en="Ide", name_az="Yazi", scientific_name="Leuciscus idus", category="river",
         habitat="Çaylar", description_az="Orta ölçülü çay balığı.", rarity="uncommon"),
    dict(name_en="Dace", name_az="Qara balıq", scientific_name="Leuciscus leuciscus", category="river",
         habitat="Dağ çayları", description_az="Sürətli axınlarda yaşayır.", rarity="common"),
    dict(name_en="Stone loach", name_az="Daşbalığı", scientific_name="Barbatula barbatula", category="river",
         habitat="Dağ çayları", description_az="Daşlı diblərdə gizlənən kiçik balıq.", rarity="common"),
    dict(name_en="Caspian salmon juvenile", name_az="Gümüşü qızılbalıq", scientific_name="Salmo trutta", category="river",
         habitat="Dağ çayları", description_az="Gənc qızılbalıq forması.", rarity="rare"),
    dict(name_en="Black sea sprat relative", name_az="Xırda siyənək", scientific_name="Clupeonella engrauliformis", category="sea",
         habitat="Xəzər", description_az="Kiçik siyənək qohumu.", rarity="common"),
    dict(name_en="Caspian herring", name_az="Xəzər siyənəyi", scientific_name="Alosa kessleri", category="sea",
         habitat="Xəzər dənizi", description_az="Böyük siyənək, yaz ovu.", rarity="uncommon", has_recipes=True),
    dict(name_en="Monkey goby", name_az="Meimun xulu", scientific_name="Neogobius fluviatilis", category="freshwater",
         habitat="Çaylar, sahil", description_az="Dib balığı.", rarity="common"),
    dict(name_en="Round goby", name_az="Dairəvi xul", scientific_name="Neogobius melanostomus", category="sea",
         habitat="Xəzər sahili", description_az="Sahil daşları arasında yaşayır.", rarity="common"),
    dict(name_en="Pipefish", name_az="İynə balığı", scientific_name="Syngnathus caspius", category="sea",
         habitat="Xəzər sahili", description_az="Uzun nazik bədənli maraqlı növ.", rarity="uncommon"),
    dict(name_en="Three-spined stickleback", name_az="Üçtikən", scientific_name="Gasterosteus aculeatus", category="freshwater",
         habitat="Sahil, çaylar", description_az="Kiçik tikənli balıq.", rarity="common"),
    dict(name_en="Weatherfish", name_az="Hava balığı", scientific_name="Misgurnus fossilis", category="freshwater",
         habitat="Bataqlıqlar", description_az="Palçıqlı sularda yaşayır.", rarity="uncommon"),
    dict(name_en="Caspian lamprey", name_az="Xəzər minəsi", scientific_name="Caspiomyzon wagneri", category="rare",
         habitat="Xəzər, çaylar", description_az="Qədim, nadir növ.", rarity="rare"),
    dict(name_en="Ship sturgeon", name_az="Şip nərə", scientific_name="Acipenser nudiventris", category="rare",
         habitat="Xəzər, Kür", description_az="Nadir nərə növü.", rarity="legendary"),
    dict(name_en="Starry sturgeon juvenile", name_az="Gənc nərə", scientific_name="Acipenser stellatus juv", category="rare",
         habitat="Kür deltası", description_az="Nərənin gənc fərdləri.", rarity="rare"),
    dict(name_en="Caspian kutum spawning", name_az="Kütüm (kürü)", scientific_name="Rutilus kutum", category="sea",
         habitat="Çay mənsəbləri", description_az="Kürü dövründə çaylara daxil olur.", rarity="uncommon"),
    dict(name_en="Mirror carp", name_az="Güzgü sazan", scientific_name="Cyprinus carpio specularis", category="freshwater",
         habitat="Göllər, hovuzlar", description_az="Az pulcuqlu sazan forması.", rarity="uncommon", has_recipes=True),
    dict(name_en="Koi carp", name_az="Koi sazan", scientific_name="Cyprinus carpio koi", category="lake",
         habitat="Dekorativ göllər", description_az="Rəngli dekorativ sazan.", rarity="uncommon"),
    dict(name_en="Channel catfish", name_az="Kanal naxası", scientific_name="Ictalurus punctatus", category="freshwater",
         habitat="Kanallar, göllər", description_az="İntroduksiya olunmuş naxa növü.", rarity="uncommon"),
    dict(name_en="Pumpkinseed", name_az="Günəş balığı", scientific_name="Lepomis gibbosus", category="lake",
         habitat="Göllər", description_az="Rəngli kiçik yırtıcı.", rarity="uncommon"),
    dict(name_en="Mosquitofish", name_az="Ağcaqanad balığı", scientific_name="Gambusia holbrooki", category="freshwater",
         habitat="Kanallar, bataqlıq", description_az="Çox kiçik, bioloji mübarizə üçün.", rarity="common"),
]


ACHIEVEMENTS = [
    dict(code="first_catch", title_az="İlk ov", description_az="İlk balığını tutdun!", icon="🎣", category="catch"),
    dict(code="species_5", title_az="5 növ", description_az="Kolleksiyanda 5 növ var.", icon="5️⃣", category="collection"),
    dict(code="species_10", title_az="10 növ", description_az="Kolleksiyanda 10 növ var.", icon="🔟", category="collection"),
    dict(code="species_25", title_az="25 növ", description_az="Kolleksiyanda 25 növ — əsl kolleksiyaçı!", icon="⭐", category="collection"),
    dict(code="river_explorer", title_az="Çay kəşfiyyatçısı", description_az="Ən azı 3 çay növü kəşf et.", icon="🏞️", category="explorer"),
    dict(code="sea_explorer", title_az="Dəniz kəşfiyyatçısı", description_az="Ən azı 3 dəniz növü kəşf et.", icon="🌊", category="explorer"),
    dict(code="lake_explorer", title_az="Göl kəşfiyyatçısı", description_az="Ən azı 3 göl növü kəşf et.", icon="💧", category="explorer"),
    dict(code="rare_hunter", title_az="Nadir balıq ovçusu", description_az="Nadir və ya əfsanəvi növ kəşf et.", icon="💎", category="rare"),
    dict(code="freshwater_master", title_az="Şirin su ustası", description_az="5 şirin su növü kəşf et.", icon="🐟", category="explorer"),
]


RECIPES = [
    dict(title_az="Sazan kababı", image_url=None, ingredients=json.dumps(["Sazan", "Soğan", "Limon", "Duz", "İstiot", "Bitki yağı"], ensure_ascii=False),
         steps=json.dumps(["Balığı təmizləyin", "Limon və ədviyyatla marinə edin", "Kömürdə və ya tavada bişirin"], ensure_ascii=False),
         cook_time_min=40, difficulty="orta", fish_species_ids="1", description_az="Klassik Azərbaycan sazan kababı."),
    dict(title_az="Kütüm plov", image_url=None, ingredients=json.dumps(["Kütüm", "Düyü", "Soğan", "Zəfəran", "Kərə yağı"], ensure_ascii=False),
         steps=json.dumps(["Balığı qızardın", "Düyünü bişirin", "Birlikdə süfrəyə verin"], ensure_ascii=False),
         cook_time_min=60, difficulty="orta", fish_species_ids="17", description_az="Xəzər kütümü ilə plov."),
    dict(title_az="Qızardılmış kefal", image_url=None, ingredients=json.dumps(["Kefal", "Un", "Duz", "Limon"], ensure_ascii=False),
         steps=json.dumps(["Balığı unlayın", "Qızardın", "Limonla verin"], ensure_ascii=False),
         cook_time_min=25, difficulty="asan", fish_species_ids="19", description_az="Sadə və dadlı sahil yeməyi."),
    dict(title_az="Naxa şorbası", image_url=None, ingredients=json.dumps(["Naxa", "Kartof", "Kök", "Soğan", "Göyərti"], ensure_ascii=False),
         steps=json.dumps(["Bulyon hazırlayın", "Tərəvəz əlavə edin", "Balıq əlavə edib bişirin"], ensure_ascii=False),
         cook_time_min=50, difficulty="orta", fish_species_ids="5", description_az="Qidalı naxa şorbası."),
    dict(title_az="Çapak qızartması", image_url=None, ingredients=json.dumps(["Çapak", "Un", "Yumurta", "Duz"], ensure_ascii=False),
         steps=json.dumps(["Balığı panə edin", "Yağda qızardın"], ensure_ascii=False),
         cook_time_min=20, difficulty="asan", fish_species_ids="9", description_az="Tez hazırlanan çapak."),
    dict(title_az="Xəşəm duzlaması", image_url=None, ingredients=json.dumps(["Xəşəm", "Duz", "Dəfnə yarpağı"], ensure_ascii=False),
         steps=json.dumps(["Balığı təmizləyin", "Duzlayın", "Soyuducuda saxlayın"], ensure_ascii=False),
         cook_time_min=30, difficulty="asan", fish_species_ids="18", description_az="Ənənəvi duzlu xəşəm."),
]


TUTORIALS = [
    dict(
        title_az="Spinning ilə atış: başlanğıc",
        description_az="Açıq üzlük spinning makara ilə düzgün atış texnikası — yeni başlayanlar üçün.",
        content_md="## Atış tövsiyələri\n\n- Əli misinaya qoyun, bail-ı açın\n- Ucun 15–20 sm boş buraxın\n- Yumşaq yelləncək, barmağı vaxtında buraxın\n- Yem suya düşəndən sonra bail-ı əllə bağlayın\n\nTəcrübə həyətyanı və ya açıq sahədə başlayın.",
        video_url="https://www.youtube.com/watch?v=yoauPIoxT5E",
        thumbnail_url="https://img.youtube.com/vi/yoauPIoxT5E/hqdefault.jpg",
        difficulty="başlanğıc", duration_min=8, category="fishing",
    ),
    dict(
        title_az="Balıqçılıq düyünləri: Palomar və Clinch",
        description_az="Qarmaq, yem və fırlanan üçün ən vacib 10 düyün — addım-addım.",
        content_md="## Düyün məsləhətləri\n\n- Palomar: braid və mono üçün ən möhkəm\n- Improved Clinch: yüngül mono üçün sürətli\n- Düyünü sıxmazdan əvvəl isladın\n- Tag ucunu 2–3 mm saxlayın\n\nPraktikada hər düyünü 5 dəfə təkrarlayın.",
        video_url="https://www.youtube.com/watch?v=3mKLbGNSvaU",
        thumbnail_url="https://img.youtube.com/vi/3mKLbGNSvaU/hqdefault.jpg",
        difficulty="başlanğıc", duration_min=16, category="equipment",
    ),
    dict(
        title_az="Sazan ovu: olta quruluşu",
        description_az="Sazan üçün çubuq, makara və sadə quraşdırma — sıfırdan.",
        content_md="## Sazan üçün əsaslar\n\n1. Orta-sərt çubuq (2.7–3.6 m)\n2. Hair rig və ya sadə dib yemi\n3. Yemi əvvəlcədən səpin, sakit gözləyin\n4. Balığı tələsik dartmayın — yorğunlaşdırın\n\nKür və göllərdə qarğıdalı / boilies yaxşı işləyir.",
        video_url="https://www.youtube.com/watch?v=t2pv64sLFGY",
        thumbnail_url="https://img.youtube.com/vi/t2pv64sLFGY/hqdefault.jpg",
        difficulty="orta", duration_min=12, category="fishing",
    ),
    dict(
        title_az="Catch & release: düzgün buraxma",
        description_az="Balığı sağ-salamat buraxmaq üçün rəsmi təlimatlar.",
        content_md="## Tutub buraxmaq\n\n- Mümkünsə suda saxlayın\n- Yalnız nəm əllə tutun, qəlsəmələrə toxunmayın\n- Dərin qarmağı zorla çıxarmayın — misinanı kəsin\n- Foto max 30 saniyə\n- Su axınına qarşı bərpa olunana qədər saxlayın\n\nİsti suda (yay) daha ehtiyatlı olun.",
        video_url="https://www.youtube.com/watch?v=_wEScRTMbKc",
        thumbnail_url="https://img.youtube.com/vi/_wEScRTMbKc/hqdefault.jpg",
        difficulty="başlanğıc", duration_min=6, category="handling",
    ),
    dict(
        title_az="Yem və lure seçimi",
        description_az="Başlayanlar üçün spinner, softbait və rəng seçimi — su şəraitinə görə.",
        content_md="## Yem seçimi\n\n- Təmiz su: təbii rənglər\n- Bulanıq su: parlaq / kontrast\n- Spinner və spoon — sadə retrieve\n- Soft plastic — yavaş, pauzalı\n\nÇökə və durnabalığı üçün spinner əla başlanğıcdır.",
        video_url="https://www.youtube.com/watch?v=SamrdgVjpQk",
        thumbnail_url="https://img.youtube.com/vi/SamrdgVjpQk/hqdefault.jpg",
        difficulty="başlanğıc", duration_min=10, category="equipment",
    ),
    dict(
        title_az="Method feeder / dib ovu quruluşu",
        description_az="Method feeder rig — qarğıdalı və pellet ilə dib balıqçılığı.",
        content_md="## Feeder əsasları\n\n1. Inline feeder + quick-change bead\n2. Qısa hooklength (~10 sm)\n3. Groundbait / mikro pellet qəlibləyin\n4. Eyni nöqtəyə atın, xətti gərgin saxlayın\n\nSazan, çapak və karas üçün idealdır.",
        video_url="https://www.youtube.com/watch?v=icGScqmXmBo",
        thumbnail_url="https://img.youtube.com/vi/icGScqmXmBo/hqdefault.jpg",
        difficulty="orta", duration_min=14, category="equipment",
    ),
    dict(
        title_az="Balığı təmizləmək və file etmək",
        description_az="Hər növ balığı sadə üsulla file etmək — başlayanlar üçün.",
        content_md="## File tövsiyələri\n\n- Kəskin, çevik file bıçağı istifadə edin\n- Qəlsənin arxasından bel sümüyünə kəsin\n- Bıçağı sümük boyunca sürüşdürün\n- Dərini quyruqdan ayırın\n- Pin sümükləri cımbızla çıxarın\n\nGigiyena: ayrıca taxta / lövhə istifadə edin.",
        video_url="https://www.youtube.com/watch?v=OkrJwglv3uk",
        thumbnail_url="https://img.youtube.com/vi/OkrJwglv3uk/hqdefault.jpg",
        difficulty="orta", duration_min=12, category="handling",
    ),
    dict(
        title_az="Sahil / surf ovu əsasları",
        description_az="Sahildən (surf) ov — çubuq, makara və sadə rig seçimi.",
        content_md="## Sahil ovu\n\n- 3–3.6 m medium-heavy spinning\n- 5000–8000 makara, braid 0.20–0.30\n- Fish-finder və ya high-low rig\n- Pyramid sinker — dalğada tutsun\n\nXəzər sahilində kefal və xəşəm üçün səhər / axşam ən yaxşıdır.",
        video_url="https://www.youtube.com/watch?v=sGpn10Houwo",
        thumbnail_url="https://img.youtube.com/vi/sGpn10Houwo/hqdefault.jpg",
        difficulty="orta", duration_min=15, category="fishing",
    ),
]


SPOTS = [
    dict(name_az="Kür çayı (Sabirabad)", latitude=40.01, longitude=48.47, description_az="Sazan, çapak və naxa üçün məşhur zona.", region="Aran"),
    dict(name_az="Araz çayı (Naxçıvan yaxınlığı)", latitude=39.20, longitude=45.40, description_az="Çay balıqları və yırtıcılar.", region="Naxçıvan"),
    dict(name_az="Xəzər sahili (Sumqayıt)", latitude=40.59, longitude=49.67, description_az="Kefal və xəşəm ovu.", region="Abşeron"),
    dict(name_az="Xəzər sahili (Lənkəran)", latitude=38.75, longitude=48.85, description_az="Cənub sahili, kütüm mövsümü.", region="Lənkəran"),
    dict(name_az="Göygöl", latitude=40.41, longitude=46.32, description_az="Dağ gölü, alabalıq və sakit ov.", region="Gəncə-Daşkəsən"),
    dict(name_az="Mingəçevir su anbarı", latitude=40.76, longitude=47.05, description_az="Böyük su hövzəsi, müxtəlif növlər.", region="Aran"),
    dict(name_az="Şamaxı gölləri", latitude=40.63, longitude=48.64, description_az="Kiçik göllər, karas və sazan.", region="Dağlıq Şirvan"),
    dict(name_az="Samur çayı", latitude=41.60, longitude=48.40, description_az="Şimal çayı, təmiz su balıqları.", region="Quba-Xaçmaz"),
]


PRODUCTS = [
    dict(name_az="Telescopic olta 3.6m", description_az="Yeni başlayanlar üçün möhkəm olta.", price_azn=45.0, images="", seller="Balıq Dünyası", category="olta", stock=25, rating=4.6),
    dict(name_az="Spinning makara 3000", description_az="Hamar yığma, metal spool.", price_azn=68.0, images="", seller="Caspian Gear", category="makara", stock=15, rating=4.8),
    dict(name_az="Spinner dəsti (5 ədəd)", description_az="Yırtıcı balıq üçün rəngli spinnerlər.", price_azn=22.0, images="", seller="Balıq Dünyası", category="yem", stock=40, rating=4.4),
    dict(name_az="Balıqçı jileti", description_az="Çox cibli, yüngül jilet.", price_azn=55.0, images="", seller="Outdoor AZ", category="geyim", stock=12, rating=4.5),
    dict(name_az="Dərinlik ölçən (sonar)", description_az="MVP demo — balıq axtarışı üçün.", price_azn=180.0, images="", seller="Caspian Gear", category="elektronika", stock=5, rating=4.7),
    dict(name_az="Keepnet / tutma toru", description_az="Balığı suda saxlamaq üçün.", price_azn=28.0, images="", seller="Balıq Dünyası", category="avadanlıq", stock=30, rating=4.3),
]


def refresh_tutorials(db: Session) -> int:
    """Delete tutorial progress + tutorials, then re-insert current TUTORIALS."""
    from app.models.content import TutorialProgress

    db.query(TutorialProgress).delete()
    db.query(Tutorial).delete()
    for row in TUTORIALS:
        db.add(Tutorial(**row))
    db.commit()
    return len(TUTORIALS)


def seed_all(db: Session, *, refresh_tutorials_data: bool = False) -> None:
    if db.query(FishSpecies).count() == 0:
        for i, row in enumerate(FISH_SPECIES):
            db.add(FishSpecies(sort_order=i, **row))
        db.flush()

    if db.query(Achievement).count() == 0:
        for row in ACHIEVEMENTS:
            db.add(Achievement(**row))

    if db.query(Recipe).count() == 0:
        for row in RECIPES:
            db.add(Recipe(**row))

    if refresh_tutorials_data:
        refresh_tutorials(db)
    elif db.query(Tutorial).count() == 0:
        for row in TUTORIALS:
            db.add(Tutorial(**row))

    if db.query(FishingSpot).count() == 0:
        for row in SPOTS:
            db.add(FishingSpot(**row))

    if db.query(MarketplaceProduct).count() == 0:
        for row in PRODUCTS:
            db.add(MarketplaceProduct(**row))

    db.commit()
