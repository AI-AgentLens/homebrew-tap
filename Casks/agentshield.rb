cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.889"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.889/agentshield_0.2.889_darwin_amd64.tar.gz"
      sha256 "38a53c3023b9e6f1592ec98e62ff5c1d2d5dfc122ecae65a913feedc423d30a3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.889/agentshield_0.2.889_darwin_arm64.tar.gz"
      sha256 "b6e623dd916ce7ef52c34dc0fc76c7f1fb82861fe4005e80813ce6caf36aab52"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.889/agentshield_0.2.889_linux_amd64.tar.gz"
      sha256 "d27fa8feaaea9b1801f8a6ce1b6f966ef591221a5cab0ede972556b43a00a7ae"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.889/agentshield_0.2.889_linux_arm64.tar.gz"
      sha256 "479cdbd4f00f1ad91215ce345f06001875049b8b303a77768652f558c35f1703"
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
