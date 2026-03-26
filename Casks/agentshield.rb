cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.77"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.77/agentshield_0.2.77_darwin_amd64.tar.gz"
      sha256 "750fcfa0c3c9596518a2fd348a3c909ead195b43f4399801f353bce8a23f8f8b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.77/agentshield_0.2.77_darwin_arm64.tar.gz"
      sha256 "70edc380001a43c7dcd48337f1b9a81910685a082fc59b3ea9090693cad81e1e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.77/agentshield_0.2.77_linux_amd64.tar.gz"
      sha256 "c4c0d1533f06e0305093ba2843b31bd3a0d411d7b03c38ab77e23ad1a3868402"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.77/agentshield_0.2.77_linux_arm64.tar.gz"
      sha256 "ffdee56636f87f37a5bd5145e1704e2677914ebfc6268ed51e143e6012dc887c"
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
