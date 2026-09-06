cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2066"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2066/agentshield_0.2.2066_darwin_amd64.tar.gz"
      sha256 "0afe7ce08b17d5fe8d826782002ceaf41627a50b800a4c65ecc48ccfabc8ef62"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2066/agentshield_0.2.2066_darwin_arm64.tar.gz"
      sha256 "8f13842658b5e02c43b2ed9fd789b856ea93876da30d110735f9ae5cbefee616"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2066/agentshield_0.2.2066_linux_amd64.tar.gz"
      sha256 "dc9acc1a27b46b1df3a0648a23ee5d3907e5761c10d2807925acc3165acf417f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2066/agentshield_0.2.2066_linux_arm64.tar.gz"
      sha256 "04e40a0a83ce7e03301f9b7edd2d149d7e2388d9a9131d540f74882d1bbec189"
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
