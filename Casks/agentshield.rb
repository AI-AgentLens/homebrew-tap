cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1906"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1906/agentshield_0.2.1906_darwin_amd64.tar.gz"
      sha256 "898171775ca1bced9babdef543477db1139654b4121492b0c3b0f3c8f63d4fb9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1906/agentshield_0.2.1906_darwin_arm64.tar.gz"
      sha256 "f1af2714cb64be19a07a67ca7689f185eff82eb4f0eef54cc5267f216960c458"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1906/agentshield_0.2.1906_linux_amd64.tar.gz"
      sha256 "3853e207d6fdde607967a2817ea15d05209d107d32863f042282120de4a7bf1d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1906/agentshield_0.2.1906_linux_arm64.tar.gz"
      sha256 "b9445e46fd348d7953a77a43a137c4c7655b48ed430fdcff38e105357a716310"
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
