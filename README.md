<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Yummy — README</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,400;9..144,600;9..144,700&family=Work+Sans:wght@400;500;600&family=IBM+Plex+Mono:wght@400;500&display=swap" rel="stylesheet">
</head>
<body>
<div class="wrap">

  <div class="receipt">
    <div class="receipt-top">
      <h1>Yummy</h1>
      <div class="receipt-sub">A restaurant survey app, built with Flutter</div>
      <div class="stars">★★★★★</div>
    </div>
    <div class="dashed"></div>
    <div class="receipt-line"><span>SURVEYS</span><span>UNLIMITED</span></div>
    <div class="receipt-line"><span>PLATFORM</span><span>FLUTTER + SUPABASE</span></div>
    <div class="receipt-line"><span>LANGUAGE</span><span>AR / EN</span></div>
  </div>
  <div class="receipt-edge"></div>

  <section style="margin-top:40px;">
    <div class="eyebrow">About</div>
    <p>Yummy lets restaurants gather structured feedback from their customers — ratings, reviews, and satisfaction surveys — and turns that data into clear insights through built-in analytics and charts.</p>
  </section>

  <section>
    <div class="eyebrow">On the Menu</div>
    <ul class="menu">
      <li><span class="menu-name">Satisfaction surveys</span><span class="menu-leader"></span><span class="menu-desc">structured feedback forms</span></li>
      <li><span class="menu-name">Ratings &amp; reviews</span><span class="menu-leader"></span><span class="menu-desc">star ratings + written comments</span></li>
      <li><span class="menu-name">Analytics dashboard</span><span class="menu-leader"></span><span class="menu-desc">charts of survey results</span></li>
      <li><span class="menu-name">Photo attachments</span><span class="menu-leader"></span><span class="menu-desc">attach dish or order photos</span></li>
      <li><span class="menu-name">Arabic &amp; English</span><span class="menu-leader"></span><span class="menu-desc">full bilingual support</span></li>
      <li><span class="menu-name">Offline mode</span><span class="menu-leader"></span><span class="menu-desc">caches locally, syncs later</span></li>
    </ul>
  </section>

  <section>
    <div class="eyebrow">Tech Stack</div>
    <table>
      <tr><th>Category</th><th>Technology</th></tr>
      <tr><td>Framework</td><td><code>Flutter</code></td></tr>
      <tr><td>Backend / auth / DB</td><td><code>supabase_flutter</code></td></tr>
      <tr><td>State management</td><td><code>flutter_bloc</code>, <code>bloc</code>, <code>equatable</code>, <code>formz</code></td></tr>
      <tr><td>Navigation</td><td><code>go_router</code></td></tr>
      <tr><td>Dependency injection</td><td><code>get_it</code>, <code>injectable</code></td></tr>
      <tr><td>Local storage</td><td><code>hive</code>, <code>shared_preferences</code></td></tr>
      <tr><td>Charts</td><td><code>fl_chart</code></td></tr>
      <tr><td>Animations</td><td><code>flutter_animate</code>, <code>lottie</code></td></tr>
      <tr><td>Networking</td><td><code>dio</code>, <code>internet_connection_checker_plus</code></td></tr>
      <tr><td>Media</td><td><code>image_picker</code>, <code>flutter_svg</code></td></tr>
      <tr><td>Localization</td><td><code>intl</code> — Cairo (AR) &amp; Poppins (EN) fonts</td></tr>
    </table>
  </section>

  <section>
    <div class="eyebrow">Supported Platforms</div>
    <div class="pills">
      <span class="pill">Android</span>
      <span class="pill">iOS</span>
      <span class="pill">Web</span>
      <span class="pill">Windows</span>
      <span class="pill">macOS</span>
    </div>
  </section>

</div>
</body>
</html>
