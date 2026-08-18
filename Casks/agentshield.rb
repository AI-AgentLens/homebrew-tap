cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1897"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1897/agentshield_0.2.1897_darwin_amd64.tar.gz"
      sha256 "73b3a790dcba8488248bd9a7b8198abdc85f4ce386eaca8f059ec428554657f7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1897/agentshield_0.2.1897_darwin_arm64.tar.gz"
      sha256 "05e1f4977bff65d65201ac00e7dfb6b93a5024fc54f7ffee060c954039f1b8f1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1897/agentshield_0.2.1897_linux_amd64.tar.gz"
      sha256 "5ec21b7f74cec19b544d7653b200ba5939ad7d1fb82bdaca099efe45ffe0aed4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1897/agentshield_0.2.1897_linux_arm64.tar.gz"
      sha256 "a69eb44ca289b42129eaf6c5a2da8faaada84b90de135d57f81bf2e1041133d6"
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
