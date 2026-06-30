cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1495"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1495/agentshield_0.2.1495_darwin_amd64.tar.gz"
      sha256 "4533c8d1a874e308333d18adb598fb0173e55334ddcd932b9ab1e49955ce7b87"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1495/agentshield_0.2.1495_darwin_arm64.tar.gz"
      sha256 "6fba9043b685c0e44934df3cb67bbd70dfa7143313b7876bb1787867f2c0b310"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1495/agentshield_0.2.1495_linux_amd64.tar.gz"
      sha256 "3ba00c790c4abd8790b9f893f1b591fe1e481f0b89105ed23caba55fd8e005e9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1495/agentshield_0.2.1495_linux_arm64.tar.gz"
      sha256 "1a4fa4ea60f0f7345f08e8c43333dd1a59d1ff0f78e1686e17a8cc9255a5d2b0"
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
