cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.327"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.327/agentshield_0.2.327_darwin_amd64.tar.gz"
      sha256 "241f5db46340c809f8e098c6cb00df9d95c26b4b291675d65cd6b88ff11698d1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.327/agentshield_0.2.327_darwin_arm64.tar.gz"
      sha256 "b27557249f805c0447801df1dac83858a6db8beb1e0fe81d9f5a0f3aeb2af811"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.327/agentshield_0.2.327_linux_amd64.tar.gz"
      sha256 "eff68d0be021cea701e96e9495472c7e550b8efed09428eece959f036862ce89"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.327/agentshield_0.2.327_linux_arm64.tar.gz"
      sha256 "dabe4b67ec07632c03572aff48b54443936968c1af291b61cf96c34af44932c0"
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
