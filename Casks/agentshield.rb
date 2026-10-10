cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2393"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2393/agentshield_0.2.2393_darwin_amd64.tar.gz"
      sha256 "b69698b4aafe123569102c26610c59ce27f7f0b10b29a198c7bc4972b18aff4e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2393/agentshield_0.2.2393_darwin_arm64.tar.gz"
      sha256 "42658268ac43f522710ee6c2d7327d21cfa2b36eff441530177b036b341f263e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2393/agentshield_0.2.2393_linux_amd64.tar.gz"
      sha256 "adf78d0d38d71b20789ee7fa529a709e875d103f76fecfd35b7ef0b69256889d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2393/agentshield_0.2.2393_linux_arm64.tar.gz"
      sha256 "15ca46e3b13cc3f6f5777008e2bc582d1c968027dd0a43341e46fd90b57573d6"
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
