require 'yaml'
require 'html-proofer'

RSpec.describe "Jekyll Site Tests" do
  before(:all) do
    # Build the site first
    system("bundle exec jekyll build --config _config.yml")
  end

  describe "Configuration" do
    it "has valid _config.yml" do
      expect { YAML.load_file('_config.yml') }.not_to raise_error
    end

    it "has valid translation files" do
      expect { YAML.load_file('_i18n/es.yml') }.not_to raise_error
      expect { YAML.load_file('_i18n/en.yml') }.not_to raise_error
    end
  end

  describe "Content Structure" do
    it "has required pages" do
      required_pages = [
        '_site/index.html',
        '_site/en/index.html',
        '_site/blog.html',
        '_site/en/blog.html',
        '_site/cv.html',
        '_site/en/resume.html'
      ]

      required_pages.each do |page|
        expect(File.exist?(page)).to be true, "Missing required page: #{page}"
      end
    end

    it "has all post translations" do
      es_posts = Dir.glob('_posts/es/*.md').map { |f| File.basename(f) }
      en_posts = Dir.glob('_posts/en/*.md').map { |f| File.basename(f) }

      es_posts.each do |post|
        expect(en_posts).to include(post), "Missing English translation for: #{post}"
      end
    end

    it "has valid frontmatter in posts" do
      all_posts = Dir.glob('_posts/**/*.md')
      
      all_posts.each do |post|
        content = File.read(post)
        frontmatter = content.split('---')[1]
        
        expect { YAML.load(frontmatter) }.not_to raise_error, "Invalid frontmatter in: #{post}"
      end
    end
  end

  describe "Generated Site" do
    it "builds without errors" do
      expect(Dir.exist?('_site')).to be true
    end

    it "has required assets" do
      expect(File.exist?('_site/assets/css/style.css')).to be true
      expect(File.exist?('_site/assets/js/main.js')).to be true
    end

    it "has security files" do
      expect(File.exist?('_site/robots.txt')).to be true
      expect(File.exist?('_site/.htaccess')).to be true
    end

    it "has proper meta tags for non-indexing" do
      index_content = File.read('_site/index.html')
      expect(index_content).to include('noindex')
    end
  end

  describe "Links and Accessibility" do
    it "has no broken internal links", :slow do
      # Configurar HTML-Proofer para verificar solo enlaces internos
      options = {
        check_external_hash: false,
        check_internal_hash: false,
        disable_external: true,
        allow_hash_href: true,
        check_html: true
      }

      expect {
        HTMLProofer.check_directory('_site', options).run
      }.not_to raise_error
    end
  end

  describe "Performance" do
    it "has reasonable CSS file size" do
      css_file = '_site/assets/css/style.css'
      if File.exist?(css_file)
        size_kb = File.size(css_file) / 1024.0
        expect(size_kb).to be < 100, "CSS file too large: #{size_kb.round(2)}KB"
      end
    end

    it "has reasonable JS file size" do
      js_file = '_site/assets/js/main.js'
      if File.exist?(js_file)
        size_kb = File.size(js_file) / 1024.0
        expect(size_kb).to be < 50, "JS file too large: #{size_kb.round(2)}KB"
      end
    end
  end
end
