cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.53"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.53/agentshield_0.2.53_darwin_amd64.tar.gz"
      sha256 "8560f0eb42ce00a89d15eac74c9a9a3ff06d82defd2f1b98e4bd1da9af8a202d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.53/agentshield_0.2.53_darwin_arm64.tar.gz"
      sha256 "2c834ffd020c72573036ab6493c22f35b1b14750cd1bcbe4aa1a483410b3a479"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.53/agentshield_0.2.53_linux_amd64.tar.gz"
      sha256 "09779d01472159c7fcadbbd2bf2bde372eec3867acbc01087e1c3a67adb128e6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.53/agentshield_0.2.53_linux_arm64.tar.gz"
      sha256 "b7cc6abc89f9373dcdbb2ca8faae73bc447516a04f9b1926c3ff8a768dac4a7a"
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
