cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1894"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1894/agentshield_0.2.1894_darwin_amd64.tar.gz"
      sha256 "df33a2a9d217deb6610534ff77d26032b12c952d751267f56511e8b685673314"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1894/agentshield_0.2.1894_darwin_arm64.tar.gz"
      sha256 "78b407754227d8408a2bba7e3fe1fa420b09b6a2a3102b9eac9d5005af6f5589"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1894/agentshield_0.2.1894_linux_amd64.tar.gz"
      sha256 "adb0377a4d6edb094ec137318d2ac2e80ddfe0e58dfe823a85132fd5216f0fe3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1894/agentshield_0.2.1894_linux_arm64.tar.gz"
      sha256 "72845ee2071164accde8c3f05e5a40733b80031beb9a283ae89161801689a509"
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
