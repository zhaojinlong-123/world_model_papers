param(
  [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'

$reportsDir = Join-Path $Root 'reports'
$papersDir = Join-Path $Root 'papers'
$docsDir = Join-Path $Root 'docs'
$paperPagesDir = Join-Path $docsDir 'papers'
$weekPagesDir = Join-Path $docsDir 'weeks'
$pdfPagesDir = Join-Path $docsDir 'pdfs'

New-Item -ItemType Directory -Force -Path $docsDir, $paperPagesDir, $weekPagesDir, $pdfPagesDir | Out-Null
Copy-Item -Path (Join-Path $papersDir '*.pdf') -Destination $pdfPagesDir -Force

function HtmlEncode([string]$Text) {
  return [System.Net.WebUtility]::HtmlEncode($Text)
}

function Convert-MarkdownLite([string]$Markdown) {
  $lines = $Markdown -split "`r?`n"
  $html = New-Object System.Collections.Generic.List[string]
  $inList = $false

  foreach ($line in $lines) {
    if ($line.Trim().Length -eq 0) {
      if ($inList) { $html.Add('</ul>'); $inList = $false }
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
      if (-not $inList) { $html.Add('<ul>'); $inList = $true }
      $html.Add("<li>$(HtmlEncode $Matches[1])</li>")
    } elseif ($line -match '^\d+\. (.+)$') {
      if (-not $inList) { $html.Add('<ul>'); $inList = $true }
      $html.Add("<li>$(HtmlEncode $Matches[1])</li>")
    } else {
      if ($inList) { $html.Add('</ul>'); $inList = $false }
      $encoded = HtmlEncode $line
      $encoded = $encoded -replace '(https?://[^\s<]+)', '<a href="$1" target="_blank" rel="noreferrer">$1</a>'
      $html.Add("<p>$encoded</p>")
    }
  }

  if ($inList) { $html.Add('</ul>') }
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
        <a href="$Depth/index.html#weekly">本周汇总</a>
        <a href="$Depth/index.html#latest">本周热点</a>
        <a href="$Depth/index.html#papers">论文报告</a>
        <a href="$Depth/index.html#watchlist">重点机构</a>
        <a href="$Depth/index.html#interest">兴趣方向</a>
      </nav>
    </header>
    <main class="page-shell">
$Body
    </main>
    <script>
      const searchInput = document.querySelector("#paperSearch");
      const clearButton = document.querySelector("#clearSearch");
      const searchStatus = document.querySelector("#searchStatus");
      const cards = Array.from(document.querySelectorAll(".hotspot-card, .paper-card, .watch-card, .interest-card"));
      const scoreButtons = Array.from(document.querySelectorAll(".score-button"));
      const exportButton = document.querySelector("#exportInterest");
      const exportBox = document.querySelector("#interestExport");
      const storageKey = "world-model-weekly-interest";

      function normalize(text) {
        return (text || "").toLowerCase().trim();
      }

      function searchableText(card) {
        return normalize([card.textContent, card.dataset.search].join(" "));
      }

      function applySearch() {
        if (!searchInput || !searchStatus) return;
        const terms = normalize(searchInput.value).split(/\s+/).filter(Boolean);
        let visibleCount = 0;

        cards.forEach((card) => {
          const matched = terms.length === 0 || terms.every((term) => searchableText(card).includes(term));
          card.hidden = !matched;
          if (matched) visibleCount += 1;
        });

        searchStatus.textContent = terms.length === 0 ? "显示全部条目" : "找到 " + visibleCount + " 个相关条目";
      }

      function readScores() {
        try {
          return JSON.parse(localStorage.getItem(storageKey) || "{}");
        } catch {
          return {};
        }
      }

      function writeScores(scores) {
        localStorage.setItem(storageKey, JSON.stringify(scores));
      }

      function applyScores() {
        const scores = readScores();
        scoreButtons.forEach((button) => {
          const selected = String(scores[button.dataset.paper] || button.dataset.defaultScore) === button.dataset.score;
          button.classList.toggle("is-active", selected);
          button.setAttribute("aria-pressed", selected ? "true" : "false");
        });
        document.querySelectorAll("[data-interest-text]").forEach((node) => {
          const paper = node.dataset.interestText;
          const defaultScore = node.dataset.defaultScore;
          const score = scores[paper] || defaultScore;
          node.textContent = "兴趣 " + score + "/5";
        });
        document.querySelectorAll("[data-interest-bar]").forEach((node) => {
          const paper = node.dataset.interestBar;
          const defaultScore = node.dataset.defaultScore;
          node.style.setProperty("--score", scores[paper] || defaultScore);
        });
      }

      scoreButtons.forEach((button) => {
        button.addEventListener("click", () => {
          const scores = readScores();
          scores[button.dataset.paper] = Number(button.dataset.score);
          scores.updated = new Date().toISOString();
          writeScores(scores);
          applyScores();
        });
      });

      exportButton?.addEventListener("click", () => {
        const scores = readScores();
        exportBox.hidden = false;
        exportBox.textContent = JSON.stringify(scores, null, 2);
      });

      searchInput?.addEventListener("input", applySearch);
      clearButton?.addEventListener("click", () => {
        searchInput.value = "";
        applySearch();
        searchInput.focus();
      });
      applyScores();
    </script>
  </body>
</html>
"@
  Set-Content -LiteralPath $Path -Value $html -Encoding UTF8
}

$paperSpecs = @(
  @{ No='01'; Slug='01_PhyWorld'; Md='01_PhyWorld.md'; Pdf='01_PhyWorld_2605.19242.pdf'; Title='PhyWorld'; Tag='Physics World Model'; Fresh='Near-week'; Interest=5; InterestReason='物理一致性和 Physical AI 仿真高度相关'; Summary='通过视频续写微调和物理偏好对齐，让视频生成模型更像可用于 Physical AI 的物理世界模拟器。' },
  @{ No='02'; Slug='02_Nano_World_Models'; Md='02_Nano_World_Models.md'; Pdf='02_Nano_World_Models_2605.23993.pdf'; Title='Nano World Models'; Tag='Reproducible WM'; Fresh='Near-week'; Interest=4; InterestReason='适合内部复现实验和方法消融'; Summary='提供极简未来视频预测实现，适合用作内部复现实验、消融分析和世界模型教学基线。' },
  @{ No='03'; Slug='03_RLA_World_Model'; Md='03_RLA_World_Model.md'; Pdf='03_Visual_Feature_RLA_2605.07079.pdf'; Title='Residual Latent Action WM'; Tag='Robot Learning'; Fresh='Recent'; Interest=5; InterestReason='机器人策略学习和动作有用表征强相关'; Summary='学习视觉特征中的残差 latent action，使世界模型更贴近机器人策略学习和动作表征。' },
  @{ No='04'; Slug='04_DriveDreamer_Policy'; Md='04_DriveDreamer_Policy.md'; Pdf='04_DriveDreamer_Policy_2604.01765.pdf'; Title='DriveDreamer-Policy'; Tag='World-Action Model'; Fresh='Recent'; Interest=5; InterestReason='世界模型和动作规划/VLA 融合'; Summary='把几何约束、语言指令、世界预测和动作规划结合起来，是 world-action model 路线的重要样本。' },
  @{ No='05'; Slug='05_Latent_Particle_World_Models'; Md='05_Latent_Particle_World_Models.md'; Pdf='05_Latent_Particle_World_Models_2603.04553.pdf'; Title='Latent Particle World Models'; Tag='Object-centric'; Fresh='Recent core'; Interest=4; InterestReason='结构化对象动态和决策学习有价值'; Summary='用对象中心的 latent particle 表征建模动态，有助于把世界模型从像素预测推进到结构化状态预测。' },
  @{ No='06'; Slug='06_ThinkJEPA'; Md='06_ThinkJEPA.md'; Pdf='06_ThinkJEPA_2603.22281.pdf'; Title='ThinkJEPA'; Tag='VLM + JEPA'; Fresh='Recent core'; Interest=4; InterestReason='VLM 语义推理指导 latent world model'; Summary='利用 VLM 语义推理引导 JEPA 式 latent 预测，体现了视觉语言模型和世界模型的融合趋势。' },
  @{ No='07'; Slug='07_WorldCache_Content_Aware'; Md='07_WorldCache_Content_Aware.md'; Pdf='07_WorldCache_Content_Aware_2603.22286.pdf'; Title='WorldCache Content-Aware'; Tag='Acceleration'; Fresh='Recent core'; Interest=4; InterestReason='世界模型部署和低延迟推理关键'; Summary='根据内容变化动态复用计算，面向世界模型和视频生成的低延迟推理。' },
  @{ No='08'; Slug='08_WorldCache_Heterogeneous_Token'; Md='08_WorldCache_Heterogeneous_Token.md'; Pdf='08_WorldCache_Heterogeneous_Token_2603.06331.pdf'; Title='WorldCache Token Caching'; Tag='Acceleration'; Fresh='Recent core'; Interest=4; InterestReason='token 级缓存可降低交互式世界模型成本'; Summary='从 token 层面做异构缓存，降低长视频和世界模型生成的重复计算成本。' },
  @{ No='09'; Slug='09_TeleWorld'; Md='09_TeleWorld.md'; Pdf='09_TeleWorld_2601.00051.pdf'; Title='TeleWorld'; Tag='4D World Model'; Fresh='Background'; Interest=5; InterestReason='4D 世界记忆和动态多模态合成非常关键'; Summary='面向 4D 世界建模和长期场景记忆，为具身智能中的空间连续性和多视角一致性提供思路。' },
  @{ No='10'; Slug='10_LongVie2'; Md='10_LongVie2.md'; Pdf='10_LongVie2_2512.13604.pdf'; Title='LongVie 2'; Tag='Ultra-long Video'; Fresh='Background'; Interest=5; InterestReason='长时序可控视频世界模型方向高度相关'; Summary='聚焦超长视频生成和跨片段一致性，对长时序模拟、交互记忆和陪伴机器人场景很有价值。' }
)

$interestDirections = @(
  @{ Direction='Physical AI world foundation models'; Score=5; Note='优先检索 Cosmos、Genesis、物理推理、具身仿真。' },
  @{ Direction='Video world models and long-horizon generation'; Score=5; Note='重点关注可控长视频、交互式视频世界模型。' },
  @{ Direction='VLA / world-action models for robotics'; Score=5; Note='重点关注动作条件、机器人策略和规划。' },
  @{ Direction='Object-centric / latent dynamics'; Score=4; Note='关注对象级状态、JEPA、latent particle 和 feature dynamics。' },
  @{ Direction='Inference acceleration'; Score=4; Note='关注缓存、token skipping、蒸馏和低延迟部署。' }
)

$hotspots = @(
  @{ Name='Cosmos 3'; Status='本周强制热点'; Note='NVIDIA 物理 AI 世界基础模型方向，后续周报会强制召回 Cosmos / Physical AI / world foundation model 相关发布。'; Link='https://research.nvidia.com/labs/cosmos-lab/cosmos3' },
  @{ Name='SANA-WM'; Status='近期核心热点'; Note='开源世界模型和可控视频生成方向，应该进入扩展口径 Top 10 或重点观察区。'; Link='https://arxiv.org/abs/2605.15178' },
  @{ Name='Gemma 4'; Status='相关基础模型观察'; Note='更偏语言/多模态推理底座，不直接挤占世界模型主榜，但会影响 VLA、规划和具身推理。'; Link='https://arxiv.org/abs/2604.07035' }
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
  $pdfRel = "../pdfs/$($paper.Pdf)"
  $paperBody = @"
      <section class="paper-hero">
        <a class="back-link" href="../index.html#papers">返回本周论文列表</a>
        <p class="eyebrow">$($paper.Tag)</p>
        <h1>$($paper.Title)</h1>
        <p class="paper-summary">$($paper.Summary)</p>
        <div class="paper-actions">
          <a class="button primary" href="$pdfRel" target="_blank" rel="noreferrer">打开原论文 PDF</a>
        </div>
      </section>
      <article class="article-body">
$body
      </article>
"@
  Write-Page -Path (Join-Path $paperPagesDir "$($paper.Slug).html") -Title "$($paper.Title) | Paper Report" -Body $paperBody -Depth '..'
}

$weeklyBody = Convert-MarkdownLite (Get-Content -LiteralPath (Join-Path $reportsDir 'weekly_summary.md') -Raw -Encoding UTF8)
Write-Page -Path (Join-Path $weekPagesDir '2026-06-04.html') -Title '2026-06-04 中文周报' -Body @"
      <section class="paper-hero">
        <a class="back-link" href="../index.html#weekly">返回主页</a>
        <p class="eyebrow">Weekly Summary</p>
        <h1>2026-06-04 世界模型与视频生成中文周报</h1>
      </section>
      <article class="article-body">
$weeklyBody
      </article>
"@ -Depth '..'

$scoreButtonsTemplate = {
  param($paper)
  $buttons = foreach ($score in 1..5) {
    "<button class=""score-button"" type=""button"" data-paper=""$($paper.Slug)"" data-score=""$score"" data-default-score=""$($paper.Interest)"">$score</button>"
  }
  return ($buttons -join '')
}

$cards = foreach ($paper in $paperSpecs) {
  $buttons = & $scoreButtonsTemplate $paper
@"
          <article class="paper-card" data-search="$($paper.No) $($paper.Title) $($paper.Tag) $($paper.Fresh) $($paper.Summary) interest $($paper.Interest) $($paper.InterestReason) world model video generation paper report">
            <span class="paper-no">$($paper.No)</span>
            <div>
              <p class="tag">$($paper.Tag) · $($paper.Fresh)</p>
              <h3>$($paper.Title)</h3>
              <p class="paper-summary">$($paper.Summary)</p>
              <div class="interest-meter" aria-label="兴趣分 $($paper.Interest) 分">
                <span data-interest-text="$($paper.Slug)" data-default-score="$($paper.Interest)">兴趣 $($paper.Interest)/5</span>
                <i data-interest-bar="$($paper.Slug)" data-default-score="$($paper.Interest)" style="--score: $($paper.Interest)"></i>
              </div>
              <div class="score-picker" aria-label="选择兴趣度">$buttons</div>
              <p class="interest-reason">$($paper.InterestReason)</p>
              <div class="card-actions">
                <a href="papers/$($paper.Slug).html">分析报告</a>
                <a href="pdfs/$($paper.Pdf)" target="_blank" rel="noreferrer">PDF</a>
              </div>
            </div>
          </article>
"@
}

$interestCards = foreach ($item in $interestDirections) {
@"
          <article class="interest-card" data-search="$($item.Direction) score $($item.Score) $($item.Note) interest direction retrieval priority">
            <p class="tag">Interest $($item.Score)/5</p>
            <h3>$($item.Direction)</h3>
            <p>$($item.Note)</p>
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
        <p class="lead">每周聚合 arXiv、OpenReview、alphaXiv、Hugging Face 和重点机构发布，优先展示本周汇总、最新热点、论文分析和下周检索权重。</p>
        <div class="hero-actions">
          <a class="button primary" href="#weekly">先看本周汇总</a>
          <a class="button" href="weeks/2026-06-04.html">打开完整中文周报</a>
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

      <section id="weekly" class="section summary-panel">
        <p class="eyebrow">Weekly First</p>
        <h2>本周汇总</h2>
        <p>本周最强信号是：世界模型正在从“生成好看的视频”转向“可用于物理推理、动作规划、长期记忆和交互仿真的系统”。对情感陪伴机器人来说，最值得投入的是可控视频世界模型、latent dynamics、VLA/world-action、长期场景记忆和低延迟部署。</p>
        <div class="summary-grid">
          <div><strong>核心趋势</strong><span>物理一致性、长时序一致性、动作条件预测、结构化 latent 和推理加速。</span></div>
          <div><strong>产品启示</strong><span>世界模型应成为机器人内部仿真层，而不是单独的视频生成模块。</span></div>
          <div><strong>检索修正</strong><span>Cosmos 3、SANA-WM、Gemma 4 进入热点/观察机制，重点机构发布强制召回。</span></div>
        </div>
        <a class="button primary" href="weeks/2026-06-04.html">阅读完整中文汇总</a>
      </section>

      <section id="latest" class="section">
        <div class="section-heading">
          <p class="eyebrow">Latest Hotspots</p>
          <h2>本周最新热点</h2>
          <p>这一栏专门放“本周必须注意”的模型、论文和项目，避免只按 PDF 批处理导致机构项目页被漏掉。</p>
        </div>
        <div class="hotspot-grid">
$($hotspotCards -join "`n")
        </div>
      </section>

      <section id="papers" class="section">
        <div class="section-heading">
          <p class="eyebrow">Paper Reports</p>
          <h2>本周论文分析</h2>
          <p>每篇论文都有中文摘要、独立分析网页、原始 PDF 链接和可选择兴趣度。</p>
        </div>
        <div class="paper-grid">
$($cards -join "`n")
        </div>
      </section>

      <section id="watchlist" class="section">
        <div class="section-heading">
          <p class="eyebrow">Institution Watchlist</p>
          <h2>重点机构监控</h2>
          <p>每周总结会优先扫描这些大型机构的论文、模型卡、技术报告、GitHub 和 Hugging Face 发布。</p>
        </div>
        <div class="watch-grid">
$($watchlistCards -join "`n")
        </div>
      </section>

      <section id="interest" class="section">
        <div class="section-heading">
          <p class="eyebrow">Interest Profile</p>
          <h2>兴趣方向与下周检索权重</h2>
          <p>点击每篇论文卡片上的 1-5 分即可在浏览器本地记录兴趣度。导出的 JSON 可用于下周更新 `sources/interest_profile.json`。</p>
        </div>
        <div class="interest-grid">
$($interestCards -join "`n")
        </div>
        <div class="export-panel">
          <button id="exportInterest" class="button" type="button">导出当前兴趣配置</button>
          <pre id="interestExport" hidden></pre>
        </div>
      </section>

      <section id="storage" class="section storage-panel">
        <p class="eyebrow">Storage Design</p>
        <h2>长期周报的轻量化存储策略</h2>
        <p>长期保存网页、Markdown 分析、来源链接和候选记录；PDF 优先保留高价值精选，避免仓库持续膨胀。当前这 10 篇 PDF 已发布到网页，后续可按兴趣分保留。</p>
        <div class="summary-grid">
          <div><strong>长期保存</strong><span>报告、网页、来源链接、候选元数据</span></div>
          <div><strong>选择保存</strong><span>每周 3-5 篇关键 PDF，普通 PDF 用官方链接访问</span></div>
          <div><strong>本地缓存</strong><span>批量下载放入 local_cache/ 或 tmp_downloads/，不提交</span></div>
        </div>
      </section>
"@

Write-Page -Path (Join-Path $docsDir 'index.html') -Title 'World Model Weekly' -Body $indexBody -Depth '.'

$css = @"
:root {
  --bg: #071018;
  --panel: rgba(12, 24, 36, 0.84);
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
.lead, .section-heading p, .summary-panel p, .storage-panel p, .article-body p, .hotspot-card p, .watch-card p, .interest-card p, .interest-reason, .paper-summary { color: var(--muted); }
.lead { max-width: 780px; font-size: 19px; }
.hero-actions, .paper-actions, .card-actions { display: flex; flex-wrap: wrap; gap: 10px; margin-top: 24px; }
.search-section, .summary-panel, .storage-panel {
  max-width: 1120px;
  border: 1px solid var(--line);
  border-radius: 8px;
  background: var(--panel);
  box-shadow: 0 18px 54px rgba(0,0,0,0.2);
}
.search-section { margin: 0 0 24px; padding: 20px; }
.search-label {
  display: block;
  margin-bottom: 10px;
  color: var(--mint);
  font-size: 12px;
  font-weight: 900;
  text-transform: uppercase;
}
.search-box { display: grid; grid-template-columns: minmax(0, 1fr) auto; gap: 10px; }
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
.search-box input:focus { border-color: var(--mint); outline: none; box-shadow: 0 0 0 3px rgba(110, 255, 192, 0.1); }
.search-box button, .score-button {
  border: 1px solid rgba(98, 230, 255, 0.34);
  border-radius: 6px;
  background: transparent;
  color: var(--ink);
  font-weight: 900;
  cursor: pointer;
}
.search-box button { min-height: 46px; padding: 0 14px; }
.search-status { margin: 10px 0 0; color: var(--muted); font-size: 14px; }
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
.summary-panel, .storage-panel { padding: 26px; }
.section-heading { max-width: 860px; margin-bottom: 24px; }
.hotspot-grid, .paper-grid, .watch-grid, .interest-grid, .summary-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 16px;
}
.paper-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
.hotspot-card, .paper-card, .watch-card, .interest-card, .article-body, .export-panel {
  border: 1px solid var(--line);
  border-radius: 8px;
  background: var(--panel);
  box-shadow: 0 18px 54px rgba(0,0,0,0.2);
}
.hotspot-card, .watch-card, .interest-card, .article-body, .export-panel { padding: 24px; }
.summary-grid { margin: 20px 0; }
.summary-grid div {
  display: grid;
  gap: 6px;
  padding: 16px;
  border: 1px solid rgba(98, 230, 255, 0.16);
  border-radius: 8px;
  background: rgba(7, 16, 24, 0.42);
}
.summary-grid strong { color: var(--mint); }
.summary-grid span { color: var(--muted); font-size: 14px; }
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
.interest-meter { display: grid; gap: 7px; margin-top: 12px; }
.interest-meter span { color: var(--mint); font-size: 12px; font-weight: 900; }
.interest-meter i {
  display: block;
  width: 100%;
  height: 7px;
  overflow: hidden;
  border: 1px solid rgba(98, 230, 255, 0.2);
  border-radius: 999px;
  background: rgba(7, 16, 24, 0.72);
}
.interest-meter i::before {
  display: block;
  width: calc((var(--score) / 5) * 100%);
  height: 100%;
  border-radius: 999px;
  background: linear-gradient(90deg, var(--cyan), var(--mint));
  content: "";
}
.score-picker { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 10px; }
.score-button { width: 34px; height: 30px; }
.score-button.is-active { background: var(--mint); color: #061018; border-color: var(--mint); }
.interest-reason, .paper-summary { margin: 10px 0 0; font-size: 14px; }
.card-actions a, .hotspot-card a, .back-link { color: var(--cyan); font-weight: 900; }
.article-body { max-width: 960px; margin-bottom: 40px; }
.article-body h1 { font-size: clamp(30px, 4vw, 44px); }
.article-body h2 { margin-top: 34px; font-size: 27px; }
.article-body h3 { margin-top: 24px; color: var(--mint); }
.article-body li { margin: 8px 0; color: var(--muted); }
.export-panel { margin-top: 18px; }
.export-panel pre {
  margin: 16px 0 0;
  overflow: auto;
  padding: 14px;
  border-radius: 6px;
  background: rgba(7, 16, 24, 0.72);
  color: var(--mint);
}

@media (max-width: 900px) {
  .hotspot-grid, .paper-grid, .watch-grid, .interest-grid, .summary-grid { grid-template-columns: 1fr; }
  .site-header { align-items: flex-start; flex-direction: column; }
  .search-box { grid-template-columns: 1fr; }
}
"@
Set-Content -LiteralPath (Join-Path $docsDir 'styles.css') -Value $css -Encoding UTF8

Write-Output "Built site at $docsDir"

