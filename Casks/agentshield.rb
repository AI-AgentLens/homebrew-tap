cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.966"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.966/agentshield_0.2.966_darwin_amd64.tar.gz"
      sha256 "6f28422e086e1d6d7d7b26c6f16f0c18b4026a7b157559a1f93a9643ecfb979b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.966/agentshield_0.2.966_darwin_arm64.tar.gz"
      sha256 "80265bc852d65ef9a9d89b0510a27cfa12b9a453dd49268995616b1ac73455e0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.966/agentshield_0.2.966_linux_amd64.tar.gz"
      sha256 "79c9a9e39c172eb64cbc6e591127e328fa61cbd0afb6892f75e3484fd1faac0c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.966/agentshield_0.2.966_linux_arm64.tar.gz"
      sha256 "5f74a51a91677b602ea926b831f0bae879b08ea8b2d5199a5e0e93e2d7673e1d"
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
