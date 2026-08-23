cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1933"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1933/agentshield_0.2.1933_darwin_amd64.tar.gz"
      sha256 "faa95f243659a4a7b6ad374ab712b5f5fe93f0821f84dc7674692895b3c7ccd8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1933/agentshield_0.2.1933_darwin_arm64.tar.gz"
      sha256 "8a019227623786e3644a508d3db6d6752fac53d4cd83c6926a6ee68a37205846"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1933/agentshield_0.2.1933_linux_amd64.tar.gz"
      sha256 "1bf70f56f09f255cff14d4d98cc7349a225ecb19540979f771a3fba5df28be56"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1933/agentshield_0.2.1933_linux_arm64.tar.gz"
      sha256 "07d4776295cb086c3c4b7586151c2c4da7d1c2bf3595fca8a1e770e5a426ec6b"
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
