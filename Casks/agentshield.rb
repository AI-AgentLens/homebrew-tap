cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1784"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1784/agentshield_0.2.1784_darwin_amd64.tar.gz"
      sha256 "307be3472355a2b225f75f33ed04374cb5fc5e90b4ff2355d65ee2761f35834a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1784/agentshield_0.2.1784_darwin_arm64.tar.gz"
      sha256 "3905396a60a7d59340c7d393edd300955a52596e33f4fd0a7d63add47cd8a0ac"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1784/agentshield_0.2.1784_linux_amd64.tar.gz"
      sha256 "9557ed19d4694117ad617f435be74b09e987be3357fb9d9876a43e42c1de1bf8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1784/agentshield_0.2.1784_linux_arm64.tar.gz"
      sha256 "dde71bece96233582efd93ef90e798e4ae3e269e49990d6ec8faa5e644d509ae"
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
