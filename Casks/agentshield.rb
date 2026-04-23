cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.704"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.704/agentshield_0.2.704_darwin_amd64.tar.gz"
      sha256 "f2b56ab1bdc87fa59956d99aa39edbc8e212978732749b23f8e220e1c063dd7f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.704/agentshield_0.2.704_darwin_arm64.tar.gz"
      sha256 "5b2bbd21c9753babe878d1aa1f7f37d703ede72556ff4474135dc0c37f8424ed"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.704/agentshield_0.2.704_linux_amd64.tar.gz"
      sha256 "a8a38c321613d2af176ed1bdd84ce396fb1df99ad34820a8d4eef198d92759ad"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.704/agentshield_0.2.704_linux_arm64.tar.gz"
      sha256 "dce851ed413b5205e0e8518694a7b28ce99aa9ab37f4b8bf2893208aefb2e0a1"
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
