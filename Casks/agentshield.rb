cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1863"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1863/agentshield_0.2.1863_darwin_amd64.tar.gz"
      sha256 "07002e96374a35eef82ab9dc2add66ccf81b132121719b439da5a71c3ce694c3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1863/agentshield_0.2.1863_darwin_arm64.tar.gz"
      sha256 "2b5c92a4cd998aa1b343751f12c1c48ae278f7d110b075765b23a6de408039bc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1863/agentshield_0.2.1863_linux_amd64.tar.gz"
      sha256 "24cb9c166906d5e5daec9a61bcac1720eeaf0ec973089c71a5bf4848bf1f7690"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1863/agentshield_0.2.1863_linux_arm64.tar.gz"
      sha256 "4f57bbd1ee5c72418f81265d9974a54cc92871896f9067aba9e253380933b212"
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
