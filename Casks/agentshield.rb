cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.436"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.436/agentshield_0.2.436_darwin_amd64.tar.gz"
      sha256 "2baa4f1aa7f764b767f3eb90faed0cef73eb679efd07b1ede557dcd955e9cc97"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.436/agentshield_0.2.436_darwin_arm64.tar.gz"
      sha256 "962694f13b50eb1c118b73cfe74f8288fc382ca1e81d2aae0beab22f2a377765"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.436/agentshield_0.2.436_linux_amd64.tar.gz"
      sha256 "1aa6e64274d595223ad3d1f09309f34e174c0d2cdec1279a36f775de6f14f053"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.436/agentshield_0.2.436_linux_arm64.tar.gz"
      sha256 "eb61bfa672ead4dac629a6970f4565306b14987232befb9834f335cdf2606339"
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
