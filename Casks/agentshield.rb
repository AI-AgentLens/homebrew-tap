cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.128"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.128/agentshield_0.2.128_darwin_amd64.tar.gz"
      sha256 "f1ab8a140bd94632cfad6f478c9f104310ec459d853adce9aa251511d8425b00"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.128/agentshield_0.2.128_darwin_arm64.tar.gz"
      sha256 "894a01b72551d73d326c32599889b9cd933ce2b5f7d2af55565d5f7c2eedb2b3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.128/agentshield_0.2.128_linux_amd64.tar.gz"
      sha256 "13e85ce0aaef6fd882c82974b02ce35e144d0910d86db7b0fd1e782434788ef3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.128/agentshield_0.2.128_linux_arm64.tar.gz"
      sha256 "44ba9fcd7c26fd3e44ac6fca50c7c49de32707055f53ed39a9ad4af16434d2c7"
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
