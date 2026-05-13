cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.969"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.969/agentshield_0.2.969_darwin_amd64.tar.gz"
      sha256 "448376a01c13264b65e5e9a492b1a35cbf73ca666b5996782e36b993cc73a7a5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.969/agentshield_0.2.969_darwin_arm64.tar.gz"
      sha256 "412cc07bf87b5a09841076212a921d91099b0239a7e5d75ea3b4723b2178786b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.969/agentshield_0.2.969_linux_amd64.tar.gz"
      sha256 "439f5d89d5b774a9169858c65044c6dba1bcd53d7744f7a9ca0c40168b66822c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.969/agentshield_0.2.969_linux_arm64.tar.gz"
      sha256 "9f294fb97e5805d61fe0b0efd60652829bf367941047aba54e9619b1f2854a58"
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
