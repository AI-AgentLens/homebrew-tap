cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.60"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.60/agentshield_0.2.60_darwin_amd64.tar.gz"
      sha256 "afca9b3f293a94c7af309c688fef99e1d9123f1817e24b1a69d846107c89f415"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.60/agentshield_0.2.60_darwin_arm64.tar.gz"
      sha256 "8f4e884537343770ccd7680cbf0e0b75643515887dc89ead3365954c54bc0ab7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.60/agentshield_0.2.60_linux_amd64.tar.gz"
      sha256 "e036691a6b7cda0bfc9d892b0485c27eea4b8be5213b122451bb97d1504a62bc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.60/agentshield_0.2.60_linux_arm64.tar.gz"
      sha256 "7264ba549401c901b1f4ca6c3781333c4ef546ccc4269c69b13394e997daaf04"
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
