cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.67"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.67/agentshield_0.2.67_darwin_amd64.tar.gz"
      sha256 "987be94ecfb85a339ae5544fe89f423004ac32b007ed1207e128cf4871f78789"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.67/agentshield_0.2.67_darwin_arm64.tar.gz"
      sha256 "0c32fb3ce9928e390fda84c7d31b2ea7c80b899d1cd4f6c5f311ee2dc6049149"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.67/agentshield_0.2.67_linux_amd64.tar.gz"
      sha256 "9fdd38e5692409a2a1740098ff730a7b36aef05c82585b76d40c0365bea478a7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.67/agentshield_0.2.67_linux_arm64.tar.gz"
      sha256 "965fc67992e3988859ff0e3db2deb1f41a11a3128838513f917cc0816042d0c2"
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
