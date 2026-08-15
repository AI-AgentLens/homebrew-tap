cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1858"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1858/agentshield_0.2.1858_darwin_amd64.tar.gz"
      sha256 "bd6b2bab8d73b48a21c368750a13acc8ec239a7aaa6a9b451c7cf843e3627ae9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1858/agentshield_0.2.1858_darwin_arm64.tar.gz"
      sha256 "a89d3d4bc4c2cf1b1d3347d5f3f1616960ba6ad69fd46edeb31da3e853400b63"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1858/agentshield_0.2.1858_linux_amd64.tar.gz"
      sha256 "54fc7336e23053e2417a04663bb8def6792ade30e3bca95933be0090c60d9a24"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1858/agentshield_0.2.1858_linux_arm64.tar.gz"
      sha256 "633d440410965e2aba3b80b4abc2718c905d919750b26601ccb6f4d742dd2913"
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
