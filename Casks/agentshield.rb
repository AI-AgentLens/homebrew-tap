cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2196"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2196/agentshield_0.2.2196_darwin_amd64.tar.gz"
      sha256 "970d5ed485de1d0f7d41d74e7de1f27d8275f502b9f9092ec52af2544287dad3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2196/agentshield_0.2.2196_darwin_arm64.tar.gz"
      sha256 "83847838a6256bdceb45e1f8631248d69a65b29521351acd550127926ce06e56"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2196/agentshield_0.2.2196_linux_amd64.tar.gz"
      sha256 "ef19599795d53fb33e4c7cbb2af28e232f2d1ab9c04d1511871c49ea13c9bc9c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2196/agentshield_0.2.2196_linux_arm64.tar.gz"
      sha256 "c7a50db10484327a112a113f1a8f7b0cab4c71ffff54254ef4816a0a1284ce09"
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
