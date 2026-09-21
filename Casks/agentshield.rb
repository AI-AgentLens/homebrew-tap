cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2215"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2215/agentshield_0.2.2215_darwin_amd64.tar.gz"
      sha256 "7ee5df5eb5eb4bb2291b401084637b7c75353e99c0cdec7b81a69cfdbcc5b3d0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2215/agentshield_0.2.2215_darwin_arm64.tar.gz"
      sha256 "3643f87a800c14910efd0febf360ba89e4f0d3158ce8b12b373a839e30059ea1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2215/agentshield_0.2.2215_linux_amd64.tar.gz"
      sha256 "785d12478bd53e3ca018783f634f0c1697364d1c7fa4d91bc68bae695d0eb48e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2215/agentshield_0.2.2215_linux_arm64.tar.gz"
      sha256 "9518abac71bc292a9c71a94e1cfaf112861a9e9d6d7fc7b1fbd54ca7a68a59ad"
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
