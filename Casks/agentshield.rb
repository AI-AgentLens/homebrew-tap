cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1760"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1760/agentshield_0.2.1760_darwin_amd64.tar.gz"
      sha256 "a29031f62c23eda0f46940692fffd5a8ac0b0caa8a04316273986ae671400912"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1760/agentshield_0.2.1760_darwin_arm64.tar.gz"
      sha256 "1c211c9075a8e1790efb4d85d1ed69f4803fa27b025efa253722ca484bcbf245"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1760/agentshield_0.2.1760_linux_amd64.tar.gz"
      sha256 "7b6cd9af01be151493a8c9cb1c991f3937d3393929dd65ef7593e2b92bfa237a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1760/agentshield_0.2.1760_linux_arm64.tar.gz"
      sha256 "b83123f892afd5be1508774c659a0b8b25cf09ba487c83e26de78fa772909973"
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
