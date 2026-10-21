cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2487"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2487/agentshield_0.2.2487_darwin_amd64.tar.gz"
      sha256 "b27dc927af9455547f4afb866d04da5624cc01f11581fc6b6cf938fa661986ec"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2487/agentshield_0.2.2487_darwin_arm64.tar.gz"
      sha256 "5b7f7e593a534b76c099761a27d2442acc90edef8a930e491e57d84d10c16a3e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2487/agentshield_0.2.2487_linux_amd64.tar.gz"
      sha256 "49a954ad95fa54af5980040d77cb5d0f2965960859f54190412d647798922c93"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2487/agentshield_0.2.2487_linux_arm64.tar.gz"
      sha256 "8f92ea5e78335ea6394b6035d579ad7aab677cabce16c1b530b2eabddb0ea4e8"
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
