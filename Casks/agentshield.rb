cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.908"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.908/agentshield_0.2.908_darwin_amd64.tar.gz"
      sha256 "e06eb5ea72ca50db44b6ad6a3221e2e12b3ea8e8598cc509bba5e6f76cd23b3d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.908/agentshield_0.2.908_darwin_arm64.tar.gz"
      sha256 "ea47e25ef2d005805110c2cd9bff78bbc8774a1d2fd77afb63f510ae47cb349c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.908/agentshield_0.2.908_linux_amd64.tar.gz"
      sha256 "7aa0faaeaf1ee145569c7b065bd9e9946d599581bb8a2ca617e7a9df4cd0aba1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.908/agentshield_0.2.908_linux_arm64.tar.gz"
      sha256 "64d7e92f36ff62d8f99eedeadb367bb407f323ef55547b771268167c111c35bb"
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
