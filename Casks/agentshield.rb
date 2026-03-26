cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.35"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.35/agentshield_0.2.35_darwin_amd64.tar.gz"
      sha256 "08df9491a654b6b6ba1bb8eda6d202ffe55a688e9bae559df0380de0d6088df2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.35/agentshield_0.2.35_darwin_arm64.tar.gz"
      sha256 "e05d19bcd9b8889b94777f30f5d8a212158aac17d0108626c838dc64aa4d6535"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.35/agentshield_0.2.35_linux_amd64.tar.gz"
      sha256 "c635c6fdf9aa9afed0e694131502dfce95cc244c402760bb1d84044ad98fcca2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.35/agentshield_0.2.35_linux_arm64.tar.gz"
      sha256 "579ccfc7b636047b5a13b734d1c87d70a5f8099873b555d97df6645b60ce4e0b"
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
