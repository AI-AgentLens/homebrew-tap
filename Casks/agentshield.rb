cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1807"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1807/agentshield_0.2.1807_darwin_amd64.tar.gz"
      sha256 "0c2840628ddf9ef3e301e48cc91fc3dfdd9770d7da458d6d321561ca17ae9003"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1807/agentshield_0.2.1807_darwin_arm64.tar.gz"
      sha256 "fdeca469c04d0de8e103f49d580bfb566554f332927760cc558be59f41f9e933"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1807/agentshield_0.2.1807_linux_amd64.tar.gz"
      sha256 "615d45893f2cb3c4070dc323be2e55fdd0eb15c546b581d5049d03db90bb48cc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1807/agentshield_0.2.1807_linux_arm64.tar.gz"
      sha256 "8d96de7fada64f6f6bfa8c8ce396c9353efcf8d46de447ffb561763f290d7a38"
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
