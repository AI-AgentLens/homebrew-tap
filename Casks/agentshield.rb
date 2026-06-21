cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1392"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1392/agentshield_0.2.1392_darwin_amd64.tar.gz"
      sha256 "9c1ac6a766d96ff35b43070580d4a4ab2eaca5e104ae3726bbda6cf875da454d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1392/agentshield_0.2.1392_darwin_arm64.tar.gz"
      sha256 "67bd7a698f29dbd88f1c8e8db82ab536867fdb3b75a2c58ba1ee98b071cb8f49"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1392/agentshield_0.2.1392_linux_amd64.tar.gz"
      sha256 "230ecc2ab242fd75f4215efb2ecc344130fcb934fe626c817d2e1eb28c0da749"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1392/agentshield_0.2.1392_linux_arm64.tar.gz"
      sha256 "fd62149f49d4df30166931556400d826dcbd4941694d7fc9c36f723e65cbf308"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
