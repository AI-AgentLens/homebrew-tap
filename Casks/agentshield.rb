cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.13"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.13/agentshield_0.2.13_darwin_amd64.tar.gz"
      sha256 "04f4d4ffb3a366a4b0ccbbe47213a9e0f7753806d5eae07adbeb72ca6b2098cf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.13/agentshield_0.2.13_darwin_arm64.tar.gz"
      sha256 "eb3e4fea842832e9fb654477df9a96eca931f0f54824c6f22290138b051fa690"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.13/agentshield_0.2.13_linux_amd64.tar.gz"
      sha256 "1404347f6599e455e5c53049216bdb219859b880ef84781d3ac2df7885bbb243"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.13/agentshield_0.2.13_linux_arm64.tar.gz"
      sha256 "9cac2c29c93889460d13a62ee2b4b2386e874e65f80cc912c3208556e3921682"
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
