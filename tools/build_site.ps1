param(
  [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'

$reportsDir = Join-Path $Root 'reports'
$papersDir = Join-Path $Root 'papers'
$docsDir = Join-Path $Root 'docs'
$paperPagesDir = Join-Path $docsDir 'papers'
$weekPagesDir = Join-Path $docsDir 'weeks'

New-Item -ItemType Directory -Force -Path $docsDir, $paperPagesDir, $weekPagesDir | Out-Null

function HtmlEncode([string]$Text) {
  return [System.Net.WebUtility]::HtmlEncode($Text)
}

function Convert-MarkdownLite([string]$Markdown) {
  $lines = $Markdown -split "`r?`n"
  $html = New-Object System.Collections.Generic.List[string]
  $inList = $false

  foreach ($line in $lines) {
    if ($line.Trim().Length -eq 0) {
      if ($inList) {
        $html.Add('</ul>')
        $inList = $false
      }
      continue
    }

    if ($line -match '^# (.+)$') {
      if ($inList) { $html.Add('</ul>'); $inList = $false }
      $html.Add("<h1>$(HtmlEncode $Matches[1])</h1>")
    } elseif ($line -match '^## (.+)$') {
      if ($inList) { $html.Add('</ul>'); $inList = $false }
      $html.Add("<h2>$(HtmlEncode $Matches[1])</h2>")
    } elseif ($line -match '^### (.+)$') {
      if ($inList) { $html.Add('</ul>'); $inList = $false }
      $html.Add("<h3>$(HtmlEncode $Matches[1])</h3>")
    } elseif ($line -match '^- (.+)$') {
      if (-not $inList) {
        $html.Add('<ul>')
        $inList = $true
      }
      $html.Add("<li>$(HtmlEncode $Matches[1])</li>")
    } else {
      if ($inList) { $html.Add('</ul>'); $inList = $false }
      $encoded = HtmlEncode $line
      $encoded = $encoded -replace '(https?://[^\s<]+)', '<a href="$1" target="_blank" rel="noreferrer">$1</a>'
      $html.Add("<p>$encoded</p>")
    }
  }

  if ($inList) {
    $html.Add('</ul>')
  }

  return ($html -join "`n")
}

function Write-Page([string]$Path, [string]$Title, [string]$Body, [string]$Depth = '..') {
  $html = @"
<!doctype html>
<html lang="zh-CN">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>$Title</title>
    <link rel="stylesheet" href="$Depth/styles.css" />
  </head>
  <body>
    <header class="site-header">
      <a class="brand" href="$Depth/index.html">World Model Weekly</a>
      <nav>
        <a href="$Depth/index.html#latest">本周热点</a>
        <a href="$Depth/index.html#papers">论文报告</a>
        <a href="$Depth/index.html#watchlist">重点机构</a>
        <a href="$Depth/index.html#trend">趋势总结</a>
      </nav>
    </header>
    <main class="page-shell">
$Body
    </main>
    <script>
      const searchInput = document.querySelector("#paperSearch");
      const clearButton = document.querySelector("#clearSearch");
      const searchStatus = document.querySelector("#searchStatus");
      const cards = Array.from(document.querySelectorAll(".hotspot-card, .paper-card, .watch-card"));

      function normalize(text) {
        return (text || "").toLowerCase().trim();
      }

      function searchableText(card) {
        return normalize([card.textContent, card.dataset.search].join(" "));
      }

      function applySearch() {
        if (!searchInput || !searchStatus) return;
        const query = normalize(searchInput.value);
        const terms = query.split(/\s+/).filter(Boolean);
        let visibleCount = 0;

        cards.forEach((card) => {
          const matched = terms.length === 0 || terms.every((term) => searchableText(card).includes(term));
          card.hidden = !matched;
          if (matched) visibleCount += 1;
        });

        searchStatus.textContent = terms.length === 0 ? "显示全部条目" : "找到 " + visibleCount + " 个相关条目";
      }

      searchInput?.addEventListener("input", applySearch);
      clearButton?.addEventListener("click", () => {
        searchInput.value = "";
        applySearch();
        searchInput.focus();
      });
    </script>
  </body>
</html>
"@
  Set-Content -LiteralPath $Path -Value $html -Encoding UTF8
}

$paperSpecs = @(
  @{ No='01'; Slug='01_PhyWorld'; Md='01_PhyWorld.md'; Pdf='01_PhyWorld_2605.19242.pdf'; Title='PhyWorld'; Tag='Physics World Model'; Fresh='Near-week' },
  @{ No='02'; Slug='02_Nano_World_Models'; Md='02_Nano_World_Models.md'; Pdf='02_Nano_World_Models_2605.23993.pdf'; Title='Nano World Models'; Tag='Reproducible WM'; Fresh='Near-week' },
  @{ No='03'; Slug='03_RLA_World_Model'; Md='03_RLA_World_Model.md'; Pdf='03_Visual_Feature_RLA_2605.07079.pdf'; Title='Residual Latent Action WM'; Tag='Robot Learning'; Fresh='Recent' },
  @{ No='04'; Slug='04_DriveDreamer_Policy'; Md='04_DriveDreamer_Policy.md'; Pdf='04_DriveDreamer_Policy_2604.01765.pdf'; Title='DriveDreamer-Policy'; Tag='World-Action Model'; Fresh='Recent' },
  @{ No='05'; Slug='05_Latent_Particle_World_Models'; Md='05_Latent_Particle_World_Models.md'; Pdf='05_Latent_Particle_World_Models_2603.04553.pdf'; Title='Latent Particle World Models'; Tag='Object-centric'; Fresh='Recent core' },
  @{ No='06'; Slug='06_ThinkJEPA'; Md='06_ThinkJEPA.md'; Pdf='06_ThinkJEPA_2603.22281.pdf'; Title='ThinkJEPA'; Tag='VLM + JEPA'; Fresh='Recent core' },
  @{ No='07'; Slug='07_WorldCache_Content_Aware'; Md='07_WorldCache_Content_Aware.md'; Pdf='07_WorldCache_Content_Aware_2603.22286.pdf'; Title='WorldCache Content-Aware'; Tag='Acceleration'; Fresh='Recent core' },
  @{ No='08'; Slug='08_WorldCache_Heterogeneous_Token'; Md='08_WorldCache_Heterogeneous_Token.md'; Pdf='08_WorldCache_Heterogeneous_Token_2603.06331.pdf'; Title='WorldCache Token Caching'; Tag='Acceleration'; Fresh='Recent core' },
  @{ No='09'; Slug='09_TeleWorld'; Md='09_TeleWorld.md'; Pdf='09_TeleWorld_2601.00051.pdf'; Title='TeleWorld'; Tag='4D World Model'; Fresh='Background' },
  @{ No='10'; Slug='10_LongVie2'; Md='10_LongVie2.md'; Pdf='10_LongVie2_2512.13604.pdf'; Title='LongVie 2'; Tag='Ultra-long Video'; Fresh='Background' }
)

$hotspots = @(
  @{ Name='Cosmos 3'; Status='本周强制热点'; Note='2026-06-01 发布，物理 AI 世界基础模型，应该进入修订版 Top 10。'; Link='https://research.nvidia.com/labs/cosmos-lab/cosmos3' },
  @{ Name='SANA-WM'; Status='近期核心热点'; Note='2.6B 开源世界模型，720p / 1 分钟可控视频生成，应进入扩展口径 Top 10。'; Link='https://arxiv.org/abs/2605.15178' },
  @{ Name='Gemma 4'; Status='附录观察'; Note='更偏语言/多模态推理底座，不应挤占世界模型/视频生成主榜，可放相关基础模型区。'; Link='https://arxiv.org/abs/2604.07035' }
)

$watchlist = @(
  @{ Lab='NVIDIA'; Focus='Cosmos / SANA / Physical AI / video world models' },
  @{ Lab='Google / DeepMind'; Focus='Gemini Robotics / world models / embodied reasoning' },
  @{ Lab='Genesis'; Focus='generative physical simulation / robot simulation ecosystem' },
  @{ Lab='Qwen / Alibaba'; Focus='multimodal models / video / agent and robotics foundations' },
  @{ Lab='DeepSeek'; Focus='reasoning models / multimodal foundations / agentic systems' },
  @{ Lab='Seed / ByteDance'; Focus='video generation / world models / embodied AI releases' }
)

foreach ($paper in $paperSpecs) {
  $mdPath = Join-Path $reportsDir $paper.Md
  $body = Convert-MarkdownLite (Get-Content -LiteralPath $mdPath -Raw -Encoding UTF8)
  $pdfRel = "../../papers/$($paper.Pdf)"
  $paperBody = @"
      <section class="paper-hero">
        <a class="back-link" href="../index.html#papers">← 返回本周论文列表</a>
        <p class="eyebrow">$($paper.Tag)</p>
        <h1>$($paper.Title)</h1>
        <div class="paper-actions">
          <a class="button" href="$pdfRel" target="_blank" rel="noreferrer">打开原论文 PDF</a>
        </div>
      </section>
      <article class="article-body">
$body
      </article>
"@
  Write-Page -Path (Join-Path $paperPagesDir "$($paper.Slug).html") -Title "$($paper.Title) | Paper Report" -Body $paperBody -Depth '..'
}

$weeklyBody = Convert-MarkdownLite (Get-Content -LiteralPath (Join-Path $reportsDir 'weekly_summary.md') -Raw -Encoding UTF8)
Write-Page -Path (Join-Path $weekPagesDir '2026-06-04.html') -Title '2026-06-04 Weekly Summary' -Body @"
      <section class="paper-hero">
        <a class="back-link" href="../index.html#trend">← 返回主页</a>
        <p class="eyebrow">Weekly Summary</p>
        <h1>2026-06-04 世界模型与视频生成周报</h1>
      </section>
      <article class="article-body">
$weeklyBody
      </article>
"@ -Depth '..'

$cards = foreach ($paper in $paperSpecs) {
@"
          <article class="paper-card" data-search="$($paper.No) $($paper.Title) $($paper.Tag) $($paper.Fresh) world model video generation paper report">
            <span class="paper-no">$($paper.No)</span>
            <div>
              <p class="tag">$($paper.Tag) · $($paper.Fresh)</p>
              <h3>$($paper.Title)</h3>
              <div class="card-actions">
                <a href="papers/$($paper.Slug).html">分析报告</a>
                <a href="../papers/$($paper.Pdf)" target="_blank" rel="noreferrer">PDF</a>
              </div>
            </div>
          </article>
"@
}

$hotspotCards = foreach ($hot in $hotspots) {
@"
          <article class="hotspot-card" data-search="$($hot.Name) $($hot.Status) $($hot.Note) hotspot institution world model video generation">
            <p class="tag">$($hot.Status)</p>
            <h3>$($hot.Name)</h3>
            <p>$($hot.Note)</p>
            <a href="$($hot.Link)" target="_blank" rel="noreferrer">查看来源</a>
          </article>
"@
}

$watchlistCards = foreach ($item in $watchlist) {
@"
          <article class="watch-card" data-search="$($item.Lab) $($item.Focus) institution watchlist world model video generation VLA physical AI">
            <h3>$($item.Lab)</h3>
            <p>$($item.Focus)</p>
          </article>
"@
}

$indexBody = @"
      <section class="hero">
        <p class="eyebrow">World Model Weekly · 2026-06-04</p>
        <h1>世界模型、视频生成与具身智能论文周报</h1>
        <p class="lead">每周聚合 arXiv、OpenReview、alphaXiv、Hugging Face 和机构技术报告，清晰展示本周最新热点、每篇论文分析和研究趋势。</p>
        <div class="hero-actions">
          <a class="button primary" href="#latest">查看本周热点</a>
          <a class="button" href="weeks/2026-06-04.html">阅读本周汇总</a>
        </div>
      </section>

      <section class="search-section" aria-label="论文检索">
        <label class="search-label" for="paperSearch">检索论文、热点和机构</label>
        <div class="search-box">
          <input id="paperSearch" type="search" placeholder="输入关键词，例如 NVIDIA、world model、VLA、video、LongVie、Cosmos..." autocomplete="off" />
          <button id="clearSearch" type="button">清空</button>
        </div>
        <p id="searchStatus" class="search-status">显示全部条目</p>
      </section>

      <section id="latest" class="section">
        <div class="section-heading">
          <p class="eyebrow">Latest Hotspots</p>
          <h2>本周最新热点</h2>
          <p>这一栏专门放“本周必须注意”的模型、论文和项目，避免只按 arXiv PDF 批处理导致 Cosmos 3、SANA-WM 这类项目被漏掉。</p>
        </div>
        <div class="hotspot-grid">
$($hotspotCards -join "`n")
        </div>
      </section>

      <section id="papers" class="section">
        <div class="section-heading">
          <p class="eyebrow">Paper Reports</p>
          <h2>本周论文分析</h2>
          <p>每篇论文都有独立网页和原始 PDF 链接，便于快速进入方法、实验、局限和产品启示。</p>
        </div>
        <div class="paper-grid">
$($cards -join "`n")
        </div>
      </section>

      <section id="watchlist" class="section">
        <div class="section-heading">
          <p class="eyebrow">Institution Watchlist</p>
          <h2>重点机构监控</h2>
          <p>每周总结会优先扫描这些大型机构的论文、模型卡、技术报告、GitHub 和 Hugging Face 发布。大型机构的 world model / video generation / VLA / physical AI 相关发布会被强制召回到候选池。</p>
        </div>
        <div class="watch-grid">
$($watchlistCards -join "`n")
        </div>
      </section>

      <section id="storage" class="section storage-panel">
        <p class="eyebrow">Storage Design</p>
        <h2>长期周报的轻量化存储策略</h2>
        <p>每周 10 篇 PDF 会让仓库快速膨胀。当前策略是长期保存网页、Markdown 分析、来源链接和候选记录；PDF 只保留少量高价值精选，其余通过官方链接访问。</p>
        <div class="storage-grid">
          <div>
            <strong>长期保存</strong>
            <span>报告、网页、来源链接、候选元数据</span>
          </div>
          <div>
            <strong>选择保存</strong>
            <span>每周 3-5 篇关键 PDF，避免普通 Git 仓库过大</span>
          </div>
          <div>
            <strong>本地缓存</strong>
            <span>批量下载放入 local_cache/ 或 tmp_downloads/，不提交</span>
          </div>
        </div>
      </section>

      <section id="trend" class="section trend-panel">
        <p class="eyebrow">Trend</p>
        <h2>本周研究趋势</h2>
        <p>世界模型正在从“生成好看的视频”转向“可用于物理推理、动作规划、长期记忆和交互仿真的系统”。最强信号包括物理一致性、长时序视频、VLA/world-action 融合、结构化 latent 表征和推理加速。</p>
        <a class="button primary" href="weeks/2026-06-04.html">打开完整汇总报告</a>
      </section>
"@

Write-Page -Path (Join-Path $docsDir 'index.html') -Title 'World Model Weekly' -Body $indexBody -Depth '.'

$css = @"
:root {
  --bg: #071018;
  --panel: rgba(12, 24, 36, 0.82);
  --panel-strong: rgba(18, 34, 50, 0.94);
  --ink: #eef7ff;
  --muted: #9eb4c4;
  --line: rgba(120, 220, 255, 0.18);
  --cyan: #62e6ff;
  --mint: #6effc0;
  --violet: #a997ff;
}

* { box-sizing: border-box; }
html { scroll-behavior: smooth; }
body {
  margin: 0;
  color: var(--ink);
  background:
    radial-gradient(circle at 78% 10%, rgba(98, 230, 255, 0.12), transparent 30%),
    radial-gradient(circle at 10% 90%, rgba(110, 255, 192, 0.09), transparent 28%),
    var(--bg);
  font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", "Microsoft YaHei", sans-serif;
  line-height: 1.62;
}

a { color: inherit; text-decoration: none; }
.site-header {
  position: sticky;
  top: 0;
  z-index: 10;
  display: flex;
  justify-content: space-between;
  gap: 20px;
  align-items: center;
  min-height: 68px;
  padding: 14px clamp(20px, 5vw, 68px);
  border-bottom: 1px solid var(--line);
  background: rgba(7, 16, 24, 0.82);
  backdrop-filter: blur(16px);
}
.brand { color: var(--cyan); font-weight: 900; }
nav { display: flex; flex-wrap: wrap; gap: 18px; color: var(--muted); font-size: 14px; }
nav a:hover { color: var(--mint); }
.page-shell { padding: 0 clamp(20px, 5vw, 68px) 72px; }
.hero, .paper-hero { padding: clamp(54px, 8vw, 112px) 0 42px; max-width: 1040px; }
.eyebrow, .tag { color: var(--mint); font-size: 12px; font-weight: 900; text-transform: uppercase; }
h1 { margin: 0; max-width: 980px; font-size: clamp(40px, 7vw, 76px); line-height: 1.04; }
h2 { margin: 0; font-size: clamp(28px, 4vw, 44px); line-height: 1.14; }
h3 { margin: 0; font-size: 20px; line-height: 1.3; }
.lead, .section-heading p, .trend-panel p, .storage-panel p, .article-body p, .hotspot-card p, .watch-card p { color: var(--muted); }
.lead { max-width: 780px; font-size: 19px; }
.hero-actions, .paper-actions, .card-actions { display: flex; flex-wrap: wrap; gap: 10px; margin-top: 24px; }
.search-section {
  max-width: 1040px;
  margin: 0 0 24px;
  padding: 20px;
  border: 1px solid var(--line);
  border-radius: 8px;
  background: var(--panel);
}
.search-label {
  display: block;
  margin-bottom: 10px;
  color: var(--mint);
  font-size: 12px;
  font-weight: 900;
  text-transform: uppercase;
}
.search-box {
  display: grid;
  grid-template-columns: minmax(0, 1fr) auto;
  gap: 10px;
}
.search-box input {
  min-width: 0;
  height: 46px;
  padding: 0 14px;
  border: 1px solid rgba(98, 230, 255, 0.28);
  border-radius: 6px;
  background: rgba(7, 16, 24, 0.88);
  color: var(--ink);
  font: inherit;
}
.search-box input:focus {
  border-color: var(--mint);
  outline: none;
  box-shadow: 0 0 0 3px rgba(110, 255, 192, 0.1);
}
.search-box button {
  min-height: 46px;
  padding: 0 14px;
  border: 1px solid rgba(98, 230, 255, 0.34);
  border-radius: 6px;
  background: transparent;
  color: var(--ink);
  font-weight: 900;
  cursor: pointer;
}
.search-status {
  margin: 10px 0 0;
  color: var(--muted);
  font-size: 14px;
}
[hidden] { display: none !important; }
.button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 42px;
  padding: 0 15px;
  border: 1px solid rgba(98, 230, 255, 0.34);
  border-radius: 6px;
  font-weight: 900;
}
.button.primary { background: linear-gradient(135deg, var(--cyan), var(--mint)); color: #061018; }
.section { padding: clamp(42px, 7vw, 86px) 0; }
.section-heading { max-width: 860px; margin-bottom: 24px; }
.hotspot-grid, .paper-grid, .watch-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 16px;
}
.paper-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
.hotspot-card, .paper-card, .watch-card, .storage-panel, .trend-panel, .article-body {
  border: 1px solid var(--line);
  border-radius: 8px;
  background: var(--panel);
  box-shadow: 0 18px 54px rgba(0,0,0,0.2);
}
.hotspot-card, .watch-card, .storage-panel, .trend-panel, .article-body { padding: 24px; }
.storage-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 14px;
  margin-top: 20px;
}
.storage-grid div {
  display: grid;
  gap: 6px;
  padding: 16px;
  border: 1px solid rgba(98, 230, 255, 0.16);
  border-radius: 8px;
  background: rgba(7, 16, 24, 0.42);
}
.storage-grid strong {
  color: var(--mint);
}
.storage-grid span {
  color: var(--muted);
  font-size: 14px;
}
.paper-card {
  display: grid;
  grid-template-columns: 54px minmax(0, 1fr);
  gap: 16px;
  padding: 20px;
}
.paper-no {
  display: grid;
  place-items: center;
  width: 42px;
  height: 42px;
  border: 1px solid rgba(110, 255, 192, 0.32);
  border-radius: 8px;
  color: var(--mint);
  font-weight: 900;
}
.card-actions a, .hotspot-card a, .back-link {
  color: var(--cyan);
  font-weight: 900;
}
.article-body {
  max-width: 960px;
  margin-bottom: 40px;
}
.article-body h1 { font-size: clamp(30px, 4vw, 44px); }
.article-body h2 { margin-top: 34px; font-size: 27px; }
.article-body h3 { margin-top: 24px; color: var(--mint); }
.article-body li { margin: 8px 0; color: var(--muted); }

@media (max-width: 900px) {
  .hotspot-grid, .paper-grid, .watch-grid { grid-template-columns: 1fr; }
  .site-header { align-items: flex-start; flex-direction: column; }
  .search-box { grid-template-columns: 1fr; }
  .storage-grid { grid-template-columns: 1fr; }
}
"@
Set-Content -LiteralPath (Join-Path $docsDir 'styles.css') -Value $css -Encoding UTF8

Write-Output "Built site at $docsDir"

