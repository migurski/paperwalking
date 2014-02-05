<h2>關於Walking Papers</h2>

<p>
    OpenstreetMap，一個任何人都可以編輯的維基化地圖，需要一個新的增加地圖內容的方式。 Walking Papers是一個透過紙圖來回(round trip) 的方式來製圖，可以使得現地調查的各種地圖資訊更容易收集，使得這個合法且簡單的註記能夠分享出去，進而轉繪為真實的地理資料。 
</p>
<p>
    Walking Papers 是一個有效的服務，實現這個以紙面地圖來製圖的想法，基於 <a href="http://mike.teczno.com/notes/walking-papers.html">
    初始的技術試驗</a> 在2009年的二月底。
</p>

<h3>三種製圖</h3>

<p>
    在OSM中，粗略的美國路網圖基本上已經完成一段時間，因為美國人口調查局的TIGER/Line資料集的輸入，這表示會對於美國的mapping party會產生一些不良的影響，mapping party通常設計給大量地需要GPS航跡的一些地方，參與者可以第一時間生產出最新的資料在這些地方，你在地圖的出現，因為訓練有素地操作，且將以一步步走在路上，所記錄的航跡發送出去。
</p>
<p>
    因為我們納稅人資助了製造免費、公開的美國公路地圖，原始的公路圖早已在資料庫中，但TIGER資料可能不準確，有了體恤人心又親切之授權的Yahooe衛星航照，使得不用離開桌前，很簡單地用OSM內建的編輯器，對於衛星影像就可以來更正這些不準確的公路，這種關著門的製圖活動在<a href="http://en.wikipedia.org/wiki/Obsessive%E2%80%93compulsive_disorder">強迫症</a>這種方面可能很有趣，我們可能花上許多時間在移動節點使得街道更加準確。
</p>
<p>
第三種方式的製圖是強調以紙圖為主的，註記上地方且眼睛可讀的圖徵，使這些圖徵可以在航照圖中看得見，有意義的但基本的公路資料庫中沒有的，不可能收集到除非到現地調查的，如路燈、腳踏車店、廁所、提款機、階梯、咖啡店、酒吧、住址和其它任何一小片與地理相關的資訊，這些更地方的資訊能使OSM更為強大且足以和商業地圖服務抗衡。
</p>

<h3>修正Fixing #3</h3>

<p>
    現在，在地方上沒有任何方法特別地設計於強調第三種的不定期休閒地方製圖。
 
</p>
<p>
    Walking Papers是一個網路服務，設定於貼近提供OpenStreetMap的紙圖印製的最後一步，使OSM地圖可以用筆做註記，掃瞄後送回電腦，再用OSM的網路編輯器Potlatch來追蹤。這是設計給休閒製圖者，他們不想在口袋中塞滿許多為了記錄週遭事物的小東西，社群製圖者帶草紙圖可能出去，加入一些註記後和朋友一起討論比較，機會主義製圖者可以在通勤或散步時，帶著紙圖並註記，最後，是設計給守舊派製圖者的，他們想要幫助OSM計畫但需要一些援助，他們可能是分散的社群團體想要將手寫註記到OSM的標籤。
</p>
<p>
    我們嘗試地橋接網路服務和舊式非數位化的製圖需求，每一張掃瞄的地圖是一個可逆轉的地理註記，這個技術使用<a href="http://www.flickr.com/services/api/flickr.places.findByLatLon.html">flickr.places.findByLatLon API feature</a>，它是一個能夠在給定的地理範圍中找到有意義地方名的服務，所以你可以看著所有人掃瞄和辨識出你可能知道的區域且幫忙製圖，理想上每一張印製和掃瞄過程中，會寄一封有列印地圖的電子郵件給使用者，且接受電子郵件的註記地圖的回覆。如果你想要玩新地理學的筆友，或者很簡單地在處理過程中就是沒有掃瞄器，那Walking Papers可以幫忙。
</p>

<h3>Context脈胳</h3>
<p>
    這個計畫最特別的地方是受到<a href="http://aaronland.info/">Aaron Cope of Flickr</a>和<a href="http://www.reallyinterestinggroup.com/">Ben / Russell / Tom at Really Interesting Group</a>的啟發，他們的<a href="http://bookcamp.pbworks.com/PaperCamp">Papercamp</a> / <a href="http://aaronland.info/talks/papernet/">Papernet</a> 和 <a href="http://www.reallyinterestinggroup.com/tofhwoti.html">Things Our Friends Have Written On The Internet 2008</a> 幫助所有這個後數位，中世紀技術合理化。
    
</p>
<p>
    <a href="mailto:info@walking-papers.org">info@walking-papers.org</a>
    <br />
    <a href="http://github.com/migurski/paperwalking">http://github.com/migurski/paperwalking</a>
</p>
