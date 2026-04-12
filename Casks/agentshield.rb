cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.553"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.553/agentshield_0.2.553_darwin_amd64.tar.gz"
      sha256 "b0e284fac252661d1cc74a3f2bb00679047babbe5c22542a10f21161ee20cf61"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.553/agentshield_0.2.553_darwin_arm64.tar.gz"
      sha256 "7bb89bcb8722e4c91976121058f3be3628fda82e0105229fb00a8683450e43ed"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.553/agentshield_0.2.553_linux_amd64.tar.gz"
      sha256 "fd5581189713f79ea6b148d1d5ad02891bbb68907af4d570c70db9f3ab653622"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.553/agentshield_0.2.553_linux_arm64.tar.gz"
      sha256 "9328e7494dd59546af1d6336c9f679bc76393f526fcef0be99c86e4189741ef9"
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
