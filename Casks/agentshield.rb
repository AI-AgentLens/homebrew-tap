cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.43"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.43/agentshield_0.2.43_darwin_amd64.tar.gz"
      sha256 "b47de0c293ce7f4574af410324e9b3385d469e5c9e9776049a5919e8370c3ca1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.43/agentshield_0.2.43_darwin_arm64.tar.gz"
      sha256 "24ae5f1a897aa38e2dd3958f99ac58351161f76aad6a34e1fe61edbf5e93a2fb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.43/agentshield_0.2.43_linux_amd64.tar.gz"
      sha256 "1270b686286e186a031c9ce24a7539b2ba84e66b665b475682a087161c6dead8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.43/agentshield_0.2.43_linux_arm64.tar.gz"
      sha256 "c2c964aacde74e20d356bec648ff10443656c811216564cd1094de8fe34a5550"
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
